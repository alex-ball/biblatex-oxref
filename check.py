#! /usr/bin/env python3
from collections import deque, defaultdict
from gettext import ngettext
import html
import os
import re
import subprocess
import typing as t

import click

CONTEXT_SETTINGS = dict(help_option_names=["-h", "--help"])


def extract_targets(filename: str) -> t.Mapping[str, str]:
    """Parses a LaTeX file and returns a mapping of IDs to target output
    extracted from `bibexbox` environments.
    """
    subprocess.run(["make", filename], check=True)
    if not os.path.isfile(filename):
        raise click.FileError(f"Could not generate {filename}.")
    print()

    targets = dict()

    GOBBLE = 0
    HEADER = 1
    TARGET = 2
    state = GOBBLE
    buffer = ""
    current_id = None
    with open(filename) as f:
        for line in f:
            if state == GOBBLE:
                if r"\begin{bibexbox}" in line:
                    state = HEADER
                    buffer += line.strip()
                else:
                    continue

            if state == HEADER:
                if current_id:
                    if line.startswith("["):
                        buffer += line.strip()
                    else:
                        buffer = ""
                        state = TARGET
                elif line.startswith(("<", "[", "{")):
                    buffer += line.strip()

                if buffer:
                    if m := re.search(
                        r"\\begin\{bibexbox\}"
                        r"(?P<state>\(.*?\))?"
                        r"(?P<source><.*?>)?"
                        r"(?P<note>\[.*?\])?"
                        r"\{(?P<id>[^}]*)\}"
                        r"(?P<opt>\[.*?\])?",
                        buffer
                    ):
                        current_id = m.group("id")
                        targets[current_id] = ""
                        if m.group("opt"):
                            buffer = ""
                            state = TARGET
                    continue

            if line.startswith(("%", "\\toggletrue")):
                continue
            if "\\tcblower" in line:
                current_id = None
                state = GOBBLE
                continue
            if targets[current_id]:
                targets[current_id] += " "
            targets[current_id] += line.strip().replace("\\@", "").replace("~", " ")

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
    print()

    # Process BBL file:
    preamble = True
    lines = list()
    current_line = list()

    def finish_record():
        lines.append(" ".join(current_line).replace("\\url {", "\\url{"))
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


def parse_simple_bibitems(lines: t.List[str]) -> t.Mapping[str, str]:
    """Parses the output from biblatex2bibitem and returns a mapping of
    IDs to actual bibitem output.
    """
    outputs = dict()

    current_id = None
    for line in lines:
        if current_id is None:
            if m := re.search(r"\\bibitem\{(?P<id>[^}]*)\}", line):
                current_id = m.group("id")
        elif line == "":
            current_id = None
        else:
            line = re.sub(r"‘(.*?)’", r"\\enquote{\1}", line)
            line = re.sub(r", (\d{4})[ab]\. ", r", \1. ", line)
            outputs[current_id] = line.replace("’", "'").replace("–", "--")

    return outputs


def contrast_refs(**kwargs: t.Mapping[str, t.Mapping[str, str]]) -> None:
    """Performs a comparison between different sets of mappings from
    bib database IDs to formatted references.

    Arguments should be given in the form of label=mapping. The label
    is used in the output printed to screen, to show the source of the
    reference text.
    """
    if not kwargs:
        raise click.ClickException("No contrast to make.")

    labels = list(kwargs.keys())

    for id, target in kwargs[labels[0]].items():
        errors = list()
        for label in labels[1:]:
            if id not in kwargs[label]:
                errors.append(f"{label} is missing ID {id}.")
            elif "(not in book)" in target:
                continue
            elif kwargs[label][id] != target:
                errors.append(f"{label}: {kwargs[label][id]}")
        if errors:
            click.secho(id, bold=True)
            click.echo(f"{labels[0]}: {target}")
            for error in errors:
                click.echo(error)
            print()


@click.command(context_settings=CONTEXT_SETTINGS)
@click.argument("style", type=click.Choice(["oxalph", "oxnotes", "oxnum", "oxyear"]))
def main(style):
    """Performs unit tests on LaTeX output from the biblatex-oxref
    bibliography styles.
    """
    targets = extract_targets(f"{style}-doc.tex")
    lines = get_bibitems(f"{style}.bbi")
    outputs = parse_simple_bibitems(lines)
    contrast_refs(Target=targets, Output=outputs)


if __name__ == "__main__":
    main()
