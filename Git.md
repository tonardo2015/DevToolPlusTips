Git tips

To fix some bugs in the middle of development, we need to temporarily save existing code changes and work on master branch.

1) git status
2) git stash
3) git checkout master
4) git checkout -b issue-101
5) git add codeChange.java
6) git commit -m "fix bug 101"
7) git switch master
8) git merge --no-ff -m "merge bug fix 101" issue-101
9) git switch dev
10) git status
12) git stash list
13) git stash apply
14) git stash drop
or 
15) git stash pop

If there are multiple "git stash", try below steps to choose which stash to use:
16) git stash list
17) git stash apply stash@{0}

To include bug fixes in master to dev branch, we can use cherry-pick

18) git branch
* dev
  master

19) git cherry-pick 4c805e2
[master 1d4b803] fix bug 101
 1 file changed, 1 insertion(+), 1 deletion(-)

Summary:

1) When there is urgent needs to fix a customer bug during development, we can create a new bug fix branch from master/main to fix the bug, then merge it to main branch, delete the bug fix branch.

2) When the development work is not completed during bug fixing task coming, we can use 'git stash' to save the current work, then switch to customer bug fixing. After that we can use 'git stash pop' to recover previous interrupted work. 

3) If we'd like to merge bug fix from master branch to current dev branch, we can use 'git cherry-pick <commit>' to copy the bug fix code changes to current branch, avoid duplicated work.

[reference](https://liaoxuefeng.com/books/git/branch/bug/index.html)
