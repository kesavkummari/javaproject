# javaproject
To Store Raw Code &amp; To Create CI/CD Pipeline



javaproject name of the repo:

main :
    Commits :
        4

dev : 
    Commits :
        6 

Want to rebase dev onto main 

git checkout main 
git merge dev 

# git rebase is a Git command that integrates changes from one branch into another

# Unlike git merge, which creates a new commit for the merge, git rebase rewrites the commit history by moving or combining a sequence of commits to a new base commit. 

# This can result in a cleaner, linear commit history.

100 commits on a branch : dev --> 1 : 6 + 4  

New Developer : 96f0456bcdb39b95724373f3a82c755634463f42



mvn clean verify sonar:sonar \
  -Dsonar.projectKey=c3ops_java_project \
  -Dsonar.projectName='c3ops_java_project' \
  -Dsonar.host.url=http://98.82.8.44:9000 \
  -Dsonar.token=sqp_a97af6604bb0b048b1578316e36fffe7729435cc