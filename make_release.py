#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Do-nothing script for making a release

This idea comes from here: 
https://blog.danslimmon.com/2019/07/15/do-nothing-scripting-the-key-to-gradual-automation/

Author: Gertjan van den Burg
Date: 2020-11-06

"""

import sys
import colorama
import os
import webbrowser

URLS = {
    # TODO
    "Travis": "https://travis-ci.org/alan-turing-institute/CleverCSV-pre-commit",
}


def colored(msg, color=None, style=None):
    colors = {
        "red": colorama.Fore.RED,
        "green": colorama.Fore.GREEN,
        "cyan": colorama.Fore.CYAN,
        "yellow": colorama.Fore.YELLOW,
        "magenta": colorama.Fore.MAGENTA,
        None: "",
    }
    styles = {
        "bright": colorama.Style.BRIGHT,
        "dim": colorama.Style.DIM,
        None: "",
    }
    pre = colors[color] + styles[style]
    post = colorama.Style.RESET_ALL
    return f"{pre}{msg}{post}"


def cprint(msg, color=None, style=None):
    print(colored(msg, color=color, style=style))


def wait_for_enter():
    input(colored("\nPress Enter to continue", style="dim"))
    print()


class Step:
    def pre(self, context):
        pass

    def post(self, context):
        wait_for_enter()

    def run(self, context):
        try:
            self.pre(context)
            self.action(context)
            self.post(context)
        except KeyboardInterrupt:
            cprint("\nInterrupted.", color="red")
            raise SystemExit(1)

    def instruct(self, msg):
        cprint(msg, color="green")

    def print_run(self, msg):
        cprint("Run:", color="cyan", style="bright")
        self.print_cmd(msg)

    def print_cmd(self, msg):
        cprint("\t" + msg, color="cyan", style="bright")

    def do_cmd(self, cmd):
        cprint(f"Going to run: {cmd}", color="magenta", style="bright")
        wait_for_enter()
        os.system(cmd)


class GitToMaster(Step):
    def action(self, context):
        self.instruct("Make sure you're on master and changes are merged in")
        self.print_run("git checkout master")


class RunTests(Step):
    def action(self, context):
        self.do_cmd("make test")


class BumpVersion(Step):
    def __init__(self, do_git=False):
        self.do_git = do_git

    def action(self, context):
        if self.do_git:
            self.do_cmd("make bump")
        else:
            self.do_cmd("make bump_nogit")


class MakeClean(Step):
    def action(self, context):
        self.do_cmd("make clean")


class PushToGitHub(Step):
    def action(self, context):
        self.do_cmd("make push")


class WaitForTravis(Step):
    def action(self, context):
        webbrowser.open(URLS["Travis"])
        self.instruct(
            "Wait for Travis to complete and verify that its successful"
        )


def main(target=None):
    colorama.init()
    procedure = [
        ("gittomaster", GitToMaster()),
        ("clean", MakeClean()),
        ("runtests", RunTests()),
        ("bumpversion_nogit", BumpVersion(do_git=False)),
        ("runtests", RunTests()),
        ("bumpversion", BumpVersion()),
        ("push", PushToGitHub(),),
        # ("travis", WaitForTravis()), TODO: Add CI integration
    ]
    context = {}
    skip = True if target else False
    for name, step in procedure:
        if not name == target and skip:
            continue
        skip = False
        step.run(context)
    cprint("\nDone!", color="yellow", style="bright")


if __name__ == "__main__":
    target = sys.argv[1] if len(sys.argv) > 1 else None
    main(target=target)
