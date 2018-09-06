# remocon
Use your favorite editor/IDE with a local git work tree, even when you need to run things on a remote host, by sending changes back and forth with almost no time/effort.

## Synopsis

### In a Terminal
- From a local interactive shell, run `remocon` within any subdir of your git work tree.
- It opens a remote shell with an identical copy of the work tree on the preconfigured host.
- Enjoy playing with the same commit and all the tracked staged/unstaged changes under the same relative working directory, but on a remote host.

![remocon live in a Terminal session running pytest remotely](https://github.com/netj/remocon/raw/gh-pages/remocon.terminal.remote-pytest.gif)


## Installation

### On macOS
You probably already have [Homebrew](https://brew.sh).
Then, just run:
```bash
 
brew install netj/tap/remocon
 
```

### On Linux/Windows/...
Download the [`remocon`](https://github.com/netj/remocon/raw/master/remocon) script and place it as an executable file on a directory on `$PATH`.

### Bash Completion
[remocon-completion.bash](remocon-completion.bash) includes programmatic completion support for bash (and perhaps other shells).
bash-completion 2 or later required.
Homebrew formula takes care of installation on macOS.
On other OS, install it manually to the right place, such as:
```bash
install -m a=r remocon-completion.bash /usr/local/etc/bash_completion.d/
```

### In MacVim (or vim)
- `:set makeprg=remocon`
- Now, <kbd>⌘B</kbd> (or `:make`) mirrors all your local edits remotely within a second.

### In IntelliJ/PyCharm
- Add to *External Tools* a *Program* `remocon` with *Working directory* set to `$ProjectFileDir$`.
    ![adding remocon as an External Tool to IntelliJ or PyCharm or any JetBrains IDE](https://github.com/netj/remocon/raw/gh-pages/remocon.idea.external-tool.gif)

- Assign a shortcut to it, say <kbd>^⌘S</kbd>, from *Keymap* in *Preferences*.
    ![assigning a keyboard shortcut for remocon in IntelliJ or PyCharm or any JetBrains IDE](https://github.com/netj/remocon/raw/gh-pages/remocon.idea.keyboard-shortcut.gif)

- Now, making all your changes appear on the remote host requires the same effort as saving any file locally.


## Usage

### How do I set up the remote host to control?
```bash
# Use the `set` command interactively:
$ remocon set
📡 Enter a remote host and path prefix to use, e.g.:
    user@example.org:tmp/repos       to put a clone of local git work tree 'foo' under 'tmp/repos/foo', or 
    example.org or user@example.org  to put all remote clones on the home dir.
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

### Is there a way to run the command in a new TMUX window, so I can inspect/debug after it finishes/aborts?
Of course.
Use the `rec` (recording) command:
```bash
$ remocon rec pytest test/
📡 [example.org] 🛰 putting a replica of local git work tree on remote
📡 [example.org] ✨ recording a new TMUX window with: pytest test/
📡 ⚠️  [example.org] attaching to the new TMUX window (TIP: append ` |:` to command-line to prevent this)
...
[detached (from session ...)] or [exited]
```

When your command takes a long time to run or for whatever reason you may feel it's awkward having to detach every time you run this command to come back to the local shell.
You probably already have another terminal attached to the remote TMUX session monitoring the activity and just want to launch the command from the local shell in the current terminal.
Here's a neat little trick for such setup: **append the ` |:` to the command-line and it won't attach but just create a new TMUX window for it**:
```bash
$ remocon rec pytest test/ |:
📡 [example.org] 🛰 putting a replica of local git work tree on remote
📡 [example.org] ✨ recording a new TMUX window with: pytest test/
```

Finally, here's a handy way to attach to the TMUX session that can be used from the other terminal:
```bash
$ remocon rec
📡 [example.org] 🛰 putting a replica of local git work tree on remote
📡 [example.org] ✨ recording a new TMUX window for an interactive session
...
```
In fact, it's `remocon`'s default behavior when in a full terminal:
```bash
$ remocon  # from a tty
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
*RemoCon* is a commonly used word for **remote controller** in Japan/Korea ([リモコン](https://ja.wikipedia.org/wiki/リモコン)/[리모컨](https://ko.wikipedia.org/wiki/리모컨)), and possibly in other countries/languages.


## History
`remocon` originates from:

- countless variations of the one-liner: `git diff | ssh ... "cd ...; git apply"`,
- then the more evolved/rigorous `git-tether-remote` function in [`git-helper` bpm module](https://github.com/netj/bpm/blob/08879b35599d013e7b247d77da74b61a7c9f4e0b/plugin/git-helper#L41-L81),
- then the gist: <https://gist.github.com/netj/54c8849681c13f11a4ec50d04041e0f3>.
