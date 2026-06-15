"""CLI entrypoint for the Crankshaft debug collector."""

from __future__ import annotations

import argparse

from .collector import collect


def build_parser() -> argparse.ArgumentParser:
    """Create and return CLI argument parser."""
    parser = argparse.ArgumentParser(
        description=(
            "Collect Crankshaft diagnostics and produce a support archive."
        )
    )
    parser.add_argument(
        "--output-dir",
        default="/tmp",
        help="Directory for output folder and tar.gz archive (default: /tmp)",
    )
    return parser


def main() -> None:
    """Parse args, execute collection, and print final artifact locations."""
    parser = build_parser()
    args = parser.parse_args()

    work_dir, archive_path, copied = collect(output_dir=args.output_dir)

    print("Debug collection complete")
    print(f"Working directory: {work_dir}")
    print(f"Archive: {archive_path}")
    if copied:
        print("Copied config/log artifacts:")
        for entry in copied:
            print(f"- {entry}")


if __name__ == "__main__":
    main()
