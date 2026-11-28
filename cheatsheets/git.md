# git cheatsheet

Your aliases: `gs` status · `ga` add · `gc` commit · `gd` diff · `gl` short graph log · `gitu` add all + commit + push · `lg` lazygit

Three places a change can be: **working tree** (edited) → `git add` → **staged** (index) → `git commit` → **commit** (history) → `git push` → **remote**.

## 1. Looking

| Command | Does |
|---|---|
| `gs` | what's changed / staged / untracked, which branch |
| `gd` | unstaged changes |
| `git diff --staged` | what will go into the next commit |
| `gl` | last 20 commits as graph |
| `git log --oneline --all --graph` | all branches |
| `git show <commit>` | one commit with its diff (`HEAD` = last, `HEAD~1` = the one before) |
| `git log -p -- file` | history of one file with diffs |
| `git log -S "text"` | commits that added / removed `text` |
| `git blame file` | who changed each line, when |

## 2. Undo — pick by where the change is

| Situation | Command |
|---|---|
| edited a file, want the last committed version back | `git restore file` ⚠ edits are gone |
| staged by mistake, keep the edits | `git restore --staged file` |
| last commit: wrong message / forgot a file | `ga file` then `git commit --amend` (`--no-edit` keeps the message) |
| undo last commit, keep changes **staged** | `git reset --soft HEAD~1` |
| undo last commit, keep changes **unstaged** | `git reset HEAD~1` |
| throw away last commit **and** its changes | `git reset --hard HEAD~1` ⚠ |
| undo a commit that's **already pushed** | `git revert <commit>` — new commit that reverses it, history stays |
| remove untracked files | `git clean -n` (preview), then `git clean -f` (`-d` folders too) |

Rule: `amend` / `reset` rewrite history → only for commits you haven't pushed. Pushed → `revert`.

## 3. "I lost something" — reflog

Every position `HEAD` has been at is kept for ~90 days, even after `reset --hard`.

```bash
git reflog                 # list: HEAD@{0}, HEAD@{1}, …  with what happened
git reset --hard HEAD@{2}  # go back to that state
git branch rescue HEAD@{2} # or: put a branch there and look at it calmly
```

## 4. Stash — put changes aside

| Command | Does |
|---|---|
| `git stash push -m "msg"` | stash tracked changes (`-u` also untracked files) |
| `git stash list` | all stashes |
| `git stash pop` | apply newest + remove it |
| `git stash apply stash@{1}` | apply a specific one, keep it |
| `git stash drop stash@{1}` | delete one |
| `git stash show -p` | what's in the newest stash |

## 5. Branches

| Command | Does |
|---|---|
| `git branch` / `git branch -a` | local / including remote branches |
| `git switch name` | go to branch |
| `git switch -c name` | create + go |
| `git switch -` | back to the previous branch |
| `git merge name` | merge `name` into the current branch |
| `git rebase main` | replay your branch's commits on top of `main` |
| `git branch -d name` | delete (only if merged; `-D` forces) |
| `git push -u origin name` | push a new branch, set upstream (afterwards plain `git push`) |
| `git push origin --delete name` | delete branch on GitHub |

## 6. Remote / syncing machines (laptop ↔ Pi)

| Command | Does |
|---|---|
| `git pull` | fetch + merge from upstream |
| `git pull --rebase` | fetch + put your local commits on top — no merge commit |
| `git fetch` | only download, change nothing — then `gl --all` or `git status` to compare |
| `git remote -v` | where `origin` points |
| `git push --force-with-lease` | force push, but refuse if someone else pushed meanwhile (never plain `--force`) |

Make `--rebase` the default once: `git config --global pull.rebase true`

## 7. Clean up history before pushing

```bash
git rebase -i HEAD~3       # last 3 commits open in nvim
# change "pick" per line to: r = reword, s = squash (into line above), f = fixup, d = drop
# reorder lines to reorder commits, save + quit to run it
git rebase --abort         # something went wrong → back to before
```

Conflict during rebase / merge: fix files → `ga file` → `git rebase --continue` (or `git merge --continue`).

## 8. Small but useful

| Command | Does |
|---|---|
| `git cherry-pick <commit>` | copy one commit onto the current branch |
| `git tag v1.0` + `git push --tags` | mark a version |
| `git commit --fixup <commit>` then `git rebase -i --autosquash <commit>~1` | fix an older commit cleanly |
| `git rm --cached file` | stop tracking a file (keeps it on disk) — then add it to `.gitignore` |
| `git check-ignore -v file` | which `.gitignore` rule matches |
