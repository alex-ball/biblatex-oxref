#! /usr/bin/env python3
import os
from pathlib import Path
import re
import subprocess
import typing as t

import click

CONTEXT_SETTINGS = dict(help_option_names=["-h", "--help"])
BIB = "bibitems"
CIT = "fullcites"


def extract_targets(filename: str) -> t.Mapping[str, t.Mapping[str, str]]:
    """Parses a LaTeX file and returns two mappings of IDs to target output
    extracted from `bibexbox` environments. The outer mapping keys are
    `fullcites` and `bibitems`.
    """
    subprocess.run(["make", filename], check=True)
    if not os.path.isfile(filename):
        raise click.FileError(f"Could not generate {filename}.")
    click.echo()

    targets = {BIB: dict(), CIT: dict()}
    undotted = list()

    GOBBLE = 0
    HEADER = 1
    TARGET = 2
    state = GOBBLE
    head_buffer = ""
    item_buffer = ""
    current_id = None
    category = CIT
    with open(filename) as f:
        for line in f:
            if state == GOBBLE:
                if "\\begin{bibexbox}" in line:
                    state = HEADER
                    category = CIT
                    head_buffer += line.strip()
                else:
                    continue

            if state == HEADER:
                if current_id:
                    if line.startswith("["):
                        head_buffer += line.strip()
                    else:
                        head_buffer = ""
                        state = TARGET
                elif line.startswith(("<", "[", "{")):
                    head_buffer += line.strip()

                if head_buffer:
                    if m := re.search(
                        r"\\begin\{bibexbox\}"
                        r"(?P<state>\(.*?\))?"
                        r"(?P<source><.*?>)?"
                        r"(?P<note>\[.*?\])?"
                        r"\{(?P<id>[^}]*)\}"
                        r"(?P<opt>\[.*?\])?",
                        head_buffer,
                    ):
                        current_id = m.group("id")
                        if m.group("opt"):
                            head_buffer = ""
                            state = TARGET
                    continue

            if line.startswith("%"):
                continue
            if line.startswith("\\toggletrue"):
                category = BIB
                continue
            if "\\tcblower" in line:
                if not item_buffer.endswith("."):
                    undotted.append(current_id)
                    item_buffer += "."
                targets[category][current_id] = item_buffer
                item_buffer = ""
                current_id = None
                state = GOBBLE
                continue
            if item_buffer:
                item_buffer += " "
            item_buffer += line.strip().replace("\\@", "").replace("~", " ")

    if undotted:
        click.echo(f"Info: added full stop to entries {', '.join(undotted)}.")
    return targets


def get_bibitems(filename: str) -> t.List[str]:
    """From a text file, extracts and returns a list of lines in a
    recurring pattern such that there is a `\\bibitem` line, followed
    by a line containing a formatted reference, followed by a blank
    line signifying the end of the reference.
    """
    # Ensure file exists and is up to date:
    subprocess.run(["make", filename], check=True)
    if not os.path.isfile(filename):
        raise click.FileError(f"Could not generate {filename}.")
    click.echo()

    # Process BBI file:
    preamble = True
    lines = list()
    current_line = list()

    def finish_record():
        line = " ".join(current_line)
        line = re.sub(r"\\([A-Za-z]+)\s+\{", r"\\\1{", line)
        lines.append(line)
        lines.append("")
        current_line.clear()

    with open(filename) as f:
        for line in f:
            # Ignore first few lines:
            if preamble:
                if line.startswith("\\bibitem"):
                    preamble = False
                else:
                    continue

            # Check for end of record
            clean_line = line.strip()
            is_eor = False
            if not clean_line:
                continue
            elif clean_line in ["{}", "\\end{thebibliography}"]:
                is_eor = True

            if is_eor:
                finish_record()
                continue

            current_line.append(clean_line)
            s = " ".join(current_line)
            if (
                s.startswith("\\bibitem")
                and s.count("[") == s.count("]")
                and s.count("{") == s.count("}")
            ):
                # `\\bibitem` line is syntactically complete
                lines.append(s)
                current_line.clear()
                continue

        if current_line:
            finish_record()

    return lines


def parse_simple_bibitems(lines: t.List[str]) -> t.Mapping[str, t.Mapping[str, str]]:
    """Parses the output from biblatex2bibitem and returns a mapping of
    IDs to actual bibitem output.
    """
    outputs = {BIB: dict(), CIT: dict()}

    category = BIB
    current_id = None
    for line in lines:
        if current_id is None:
            if m := re.search(r"\\bibitem\{(?P<id>[^}]*)\}", line):
                current_id = m.group("id")
            elif line.startswith("References"):
                category = CIT
        elif line == "":
            current_id = None
        else:
            line = re.sub(r"“\{”(.*?)\}", r"\\enquote{\1}", line)
            line = re.sub(r"‘(.*?)’(?!\w)", r"\\enquote{\1}", line)
            line = re.sub(r"(?<!\w)\{(.*?)\}(?!\w)", r"\1", line)
            outputs[category][current_id] = (
                line.replace("’", "'").replace("\\@", "").replace("~", " ")
            )

    return outputs


def contrast_refs(**kwargs: t.Mapping[str, t.Mapping[str, str]]) -> t.Mapping[str, int]:
    """Performs a comparison between different sets of mappings from
    bib database IDs to formatted references.

    Arguments should be given in the form of label=mapping. The label
    is used in the output printed to screen, to show the source of the
    reference text.
    """
    if not kwargs:
        raise click.ClickException("No contrast to make.")

    labels = list(kwargs.keys())
    stats = {"passed": 0, "skipped": 0}

    for id, target in kwargs[labels[0]].items():
        errors = list()
        skippable = "(not in book)" in target
        ambiguous = (  # Should we ignore disambiguation letters?
            (re.search(r"\(([–\d]+)\\emph\{[ab]\}\)", target) is None)
            if not skippable
            else False
        )
        for label in labels[1:]:
            if id not in kwargs[label]:
                errors.append(f"{label} is missing ID {id}.")
            elif skippable:
                stats["skipped"] += 1
            else:
                if ambiguous:
                    kwargs[label][id] = re.sub(
                        r"\(([–\d]+)\\emph\{[ab]\}\)", r"(\1)", kwargs[label][id]
                    )
                if kwargs[label][id] == target:
                    stats["passed"] += 1
                else:
                    errors.append(f"{label}: {kwargs[label][id]}")
        if errors:
            click.secho(id, bold=True)
            click.echo(f"{labels[0]}: {target}")
            for error in errors:
                click.echo(error)
            click.echo()

    return stats


def parse_log(jobname: str):
    logfile = Path(f"{jobname}.log")

    if not logfile.is_file():
        return

    error_lines = list()
    capture_til_blank = False
    with open(logfile) as f:
        for whole_line in f:
            line = whole_line.strip()
            if line.startswith("! ") or line.startswith("Package biblatex Warning"):
                capture_til_blank = True
                error_lines.extend(["", line])
                continue
            elif line.startswith("WARNING: biblatex-oxref"):
                error_lines.extend(["", line])
                continue

            if capture_til_blank:
                if not line:
                    capture_til_blank = False
                else:
                    error_lines.append(line)

    if error_lines:
        click.echo("\nErrors and warnings from log file:")
        for line in error_lines:
            click.echo(f"  {line}")
        click.echo()


def run_lbx_check(jobname: str):
    filename = f"{jobname}.pdf"
    try:
        subprocess.run(["make", filename], check=True)
    except subprocess.CalledProcessError as e:
        parse_log(jobname)
        raise click.ClickException(f"LaTeX run did not complete successfully.\n{e}")

    parse_log(jobname)
    if not os.path.isfile(filename):
        raise click.FileError(f"Could not generate {filename}.")
    click.echo("Compilation successful.")


@click.command(context_settings=CONTEXT_SETTINGS)
@click.argument(
    "style", type=click.Choice(["oxalph", "oxnotes", "oxnum", "oxyear", "spanish"])
)
def main(style):
    """Performs unit tests on LaTeX output from the biblatex-oxref
    bibliography styles.
    """
    if style in ["spanish"]:
        return run_lbx_check(f"test-{style}")

    targets = extract_targets(f"{style}-doc.tex")
    lines = get_bibitems(f"{style}.bbi")
    outputs = parse_simple_bibitems(lines)
    click.echo(
        click.style("Targets:", bold=True)
        + f" {len(targets[BIB])} {BIB}, {len(targets[CIT])} {CIT}. "
        + click.style("Outputs:", bold=True)
        + f" {len(outputs[BIB])} {BIB}, {len(outputs[CIT])} {CIT}.\n"
    )
    stats = dict()
    stats[BIB] = contrast_refs(Target=targets[BIB], Output=outputs[BIB])
    stats[CIT] = contrast_refs(Target=targets[CIT], Output=outputs[CIT])
    for key in [BIB, CIT]:
        fails = len(targets[key])
        for stat in stats[key].values():
            fails -= stat
        stats[key]["failed"] = fails
        click.echo(
            click.style(f"Test {key}:", bold=True)
            + f" {stats[key]['passed']} passed;"
            + f" {stats[key]['skipped']} skipped;"
            + f" {stats[key]['failed']} failed."
        )
    parse_log(f"test-{style}")


if __name__ == "__main__":
    main()
