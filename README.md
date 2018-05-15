# remocon
Use your favorite editor/IDE with a local git work tree, even when you need to run things on a remote host, by sending changes back and forth with almost no time/effort.

## Synopsis

### In a Terminal
- From a local interactive shell, run `remocon` within any subdir of your git work tree.
- It opens a remote shell with an identical copy of the work tree on the preconfigured host.
- Enjoy playing with the same commit and all the tracked staged/unstaged changes under the same relative working directory, but on a remote host.

### In MacVim (or vim)
- `:set makeprg=remocon`
- Now, <kbd>⌘B</kbd> (or `:make`) mirrors all your local edits remotely within a second.

### In IntelliJ/PyCharm
- Add to *External Tools* a *Program* `remocon` with *Working directory* set to `$ProjectFileDir$`.
- Assign a shortcut to it, say <kbd>^⌘S</kbd>, from *Keymap* in *Preferences*.
- Now, making all your changes appear on the remote host requires the same effort as saving any file locally.


## Installation

### On macOS
You probably already have [Homebrew](https://brew.sh).
Then, just run:
```bash
brew install netj/tap/remocon
```

### On Linux/Windows/...
Download the [`remocon`](https://github.com/netj/remocon/raw/master/remocon) script and place it as an executable file on a directory on `$PATH`.


## Usage

### How do I set up the remote host to control?
```bash
# Use the `set` command interactively:
$ remocon set
📡 Enter a remote host and path prefix to use (e.g., example.org or user@example.org or user@example.org:path/prefix/to/repos): 
>>> user@somewhere.org:some/path
📡 [user@somewhere.org:some/path] ⚙️ setting ~/.remocon.conf
```

```bash
# Or pass the remote host and optional path prefix as argument:
$ remocon set example.org
📡 [example.org] ⚙️ setting ~/.remocon.conf
```

```bash
# Or edit the configuration file directly:
$ vim ~/.remocon.conf
remote=user@somewhere.org:some/path
remote=example.org
```

### How do I put a replica of my local git repo on the remote host?
```bash
# Use the `put` command:
$ remocon put
📡 [example.org] 🛰 putting a replica of local git work tree on remote
...
```
```bash
# Or it's the default behavior when not in a full terminal:
$ remocon  # from a non-tty, e.g., in MacVim or IntelliJ
```

### How do I open an interactive/login shell for the remote git repo?
```bash
# Use the `run` command:
$ remocon run
📡 [example.org] 🛰 putting a replica of local git work tree on remote
...
📡 [example.org] ⚡️ running command: bash -il
...
```
```bash
# Or it's the default behavior when not in a full terminal:
$ remocon  # from a tty
```
```bash
# You can open a different shell than `bash` if wanted:
$ remocon run zsh -l
```

### How do I run a command on the remote git repo?
```bash
# In fact, you can run any commands with the latest changes in local work tree:
$ remocon run make test
$ remocon run pytest src/
$ remocon run mvn test
$ remocon run jupyter notebook
```

```bash
# Remote commands are run under the identical relative subdir to where you run remocon locally, so launching a server that is workdir-sensitive can be hassle-free:
$ cd server
$ remocon run docker-compose up -d
...
$ cd -
```

```bash
# You can also launch a REPL for Python
$ remocon run python
...
>>> 1+1
2
```

```bash
# Or even an editor to edit/view remote files:
$ remocon run vim
```

### How do I get remotely generated data or code edits back to my local git repo?
For example, maybe your commands generated important data remotely.
Or you made precious changes to the code remotely while testing/debugging interactively.

```bash
# To get everything under the workdir:
$ remocon get
📡 [example.org] 💎 getting remote files under 1 paths: .
...
```

```bash
# You can specify a list of file/directory names to get back from remote:
$ remocon get Untitled.ipynb Experiment.ipynb
$ remocon get test/report.xml
$ remocon get src/server/easy_to_debug_remotely.py
$ remocon get src/main/java/
```

### Is there a way to put my changes, run a command, then get specific output back?
```bash
# Use the `prg` (p/ut, r/un, g/et) round-trip "programming" command:
$ remocon prg test/report.xml test/log.txt -- make test
📡 [example.org] 🛰 putting a replica of local git work tree on remote
...
📡 [example.org] ⚡️ running command: make test
...
📡 [example.org] 💎 getting remote files under 2 paths: test/report.xml test/log.txt
...
```



## Why `remocon`?

### Why not just `git commit` and `push`?
- `remocon` frees you from having to `git commit` and `git push` every little change.

### Why not just use *Tools* > *Deployment* in IntelliJ/PyCharm?
- `remocon` supersedes your IDE's sluggish remote deployment function that typically relies on SFTP wasting time/effort requiring you to guess and upload a whole bunch of changed files whenever you checkout a pretty different git branch.

### What's wrong with my beautiful remote sessions?
- TMUX, Bash, and Vim/Emacs in terminals are a beautiful thing, but using them exclusively may not be the most productive work environment for you, nor the healthiest.
    - No matter how close your remote host is, there's always a few msec of latency added to every keystroke you make when working/editing remotely, which can create significant fatigue and numbness over long period of time while you may not even recognize.
    - By limiting your exposure to such hazardous conditions to a minimum when they're absolutely needed, and keeping the rest of the time in an optimal local work environment, you can become a lot more productive.

### Okay. So, should I abandon my remote setup and switch to `remocon` entirely?
- Not really.  `remocon` is only going to be complementary.  Your nice dotfiles on remote hosts will still remain an integral piece of the workflow.
    - `remocon` reduces the need for setting up an SSH session to a remote host (logging in, changing directories with `cd`, messing with `git pull` and `git checkout`, etc.), just to run some quick test commands on an identical copy of the code you have locally.
    - `remocon` enables quick switching between hosts of a shared cluster, e.g., when the current host gets too crowded, crashes, or whatever else goes wrong with it, you no longer need to become a hostage/victim of such situation/accident.  Just point `.remocon.conf` to another host and with a bit of initial git clone time, any fresh host becomes yours without changing workflow too much or having to move too many things.


## Trivia
*RemoCon* is a common abbreviation for **remote controller** in Japan/Korea, and possibly in several other countries/languages.


## History
`remocon` originates from:

- countless variations of the one-liner: `git diff | ssh ... "cd ...; git apply"`,
- then the more evolved/rigorous `git-tether-remote` function in [`git-helper` bpm module](https://github.com/netj/bpm/blob/08879b35599d013e7b247d77da74b61a7c9f4e0b/plugin/git-helper#L41-L81),
- then the gist: <https://gist.github.com/netj/54c8849681c13f11a4ec50d04041e0f3>.
