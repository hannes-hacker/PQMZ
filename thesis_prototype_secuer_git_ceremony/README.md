# Description
This directory represents the implementation of the section "SECUER" in the paper.

The implementation is divided into three repositories utilizing Git technology:
access point GitHub repository, mirroring CI pipeline on Gitlab repository
and secure storage on Gitlab according to the architecture provided in the paper.

You have to set up your GitHub and Gitlab instances by yourself. The necessary information is provided in the following text
but the setup can be changed accordingly to fit other needs and preferences.

More thorough information can be obtained by reading the according paper, and inspecting the source code
and configuration files.

## Access point on GitHub repository
This repository is deployed on GitHub and represents the access point for all participants of this multi-party computation protocol.

Therefore, it holds an instance of the C-implementation provided by Basso *et al.* (https://github.com/trusted-isogenies/SECUER-pok/tree/main/c-impl) to distribute the necessary tools for all participants and has to be built accordingly (described in the link).

Additionally, three new directories have been created:

1. curves: describes the verified set of curves
2. proofs: describes the verified set of proofs
3. new_additions: holds at every time a ".gitkeep" file to not be deleted automatically by Git
   		         but generally describes the directory for adding the participant's curve and proof files to be tested and potentially added to the sequences


The provided SECUER tools have to be utilized to initialize this repository
(has already been done in this instance but the following commands can be used for new additions):

1. Creation of an (initial) proof and putting in the "proofs" directory
   1.1 utilizing j-invariant: 	./prove_* --initial > proof0.txt (only relevant for initialization)
   1.2 utilizing curve:	      	tail -n 1 curve1.txt | ./prove_* > proof1.txt

2. Creation of an (inital) curve and putting in the "curves" directory
   utilizing the (initial) proof:	./verify_* < proof0.txt > curve1.txt

--> you usually use 1.2 and 2 for creating your additions and saving them in the "new_additions" directory


### Settings

For the protection of the repository, the following settings should be utilized:

1. visibility (GitHub: "Settings/General"): we used public for our test setup
2. rules (GitHub: "Settings/Rules/Ruleset"): we enforced the usage of pull requests and blocked force pushes

Further restrictions can increase the security of the protocol.

### Connection to "CI pipeline on Gitlab"
Our architecture for this system connects this repository to a Gitlab repository with integrated CI functionality.
Hence, the configuration file ".gitlab-ci.yml" has to be set in this repository.
You can check our example in the provided setup.

## Mirroring CI pipeline on Gitlab repository
This repository is deployed on Gitlab, provides the CI pipeline and the execution environment for the background checks to fulfill
the properties of this multi-party computation protocol.

Therefore, it connects to the GitHub repository by mirroring said repository. The connection was made by personal access tokens
like described in the documentation (https://docs.gitlab.com/ci/ci_cd_for_external_repos/github_integration/ - you need to use
the section "Connect with personal access token"). This process is necessary for and requires additionally enabling pull mirroring, the GitHub integration
and creating a web hook in GitHub so that the Gitlab repository will be messaged on new pull requests.

Since the scripts, which are placed in the third repository, are executed on this repository, respective access tokens have to be
saved here. So, we created variables in Gitlab: "Settings/CICD/Variables" and only enabled the option "Masked and hidden" for
not exposing the token.
We used the label "ACCESS_GITHUB_TOKEN" for connecting to GitHub and "AUTOMATION_ACCESS_TOKEN" to the secure storage Gitlab
repository.
The mentioned access token (paragraph above) can be used for that or a new one can be created in GitHub:
"(Profile) Settings/DeveloperSettings/Personal access tokens/Fine-grained tokens" with read and write access.

## Secure storage on Gitlab repository
This repository is deployed on Gitlab and stores a reliable instance of the SECUER tools, the reference hashes for checking if
somebody manually changed the verified curves and proofs and the scripts employed for the CI pipeline to fulfill the properties of
this multi-party computation protocol.

Therefore, it connects to the CI Gitlab repository by providing an access token. Such a token can be created in the
repository in Gitlab: "Settings/Access tokens" with write permissions.
This token is saved in the other Gitlab repository in the "AUTOMATION_ACCESS_TOKEN" variable.

### Secure storage
This repository stores the scripts which are utilized by the CI pipeline. We created the following scripts, respective to the stage
in the pipeline: test_directories.sh (stage structure) and test_additions.sh (stage structure) in parallel, test_verify.sh (stage verification).
Examples are given in our provided setup.

Besides, it stores a reliable and safe instance of the SECUER tools (https://github.com/trusted-isogenies/SECUER-pok/) which are built and utilized by the scripts to utilize a trustworthy instance of the original SECUER protocol project.

Finally, it stores the references hashes over the latest, correct state of the verified curves and proofs. This has to be
initialized, too (has already been done in this instance but the following commands can be used for an own setup).
After placing the initial curve and proof (like described in "Access point on GitHub repository") in the according directories, 
the following commands can be executed to initialize the respective hashes:
1. creating hash value for the initial curve: sha256sum c-impl/curves/* | sha256sum | head -c64 (and copy it in "curves.txt")
2. creating hash value for the initial proof: sha256sum c-impl/proofs/* | sha256sum | head -c64 (and copy it in "proofs.txt")

**NOTE:** Keep in mind that we are using these commands in the scripts. If you are creating the hashes, e.g. in the directory c-impl,
then the script has to be changed accordingly because this changes the hash values when applying the hash function twice like in the scripts.


# Additional Notes
The GitHub repository was named "secuer_ceremony_access", the CI Gitlab "secuer_ceremony_access" and secure storage Gitlab repository "secuer_ceremony_storage".
These labels are also used in the scripts and would have to be changed accordingly if the names of the directories are changed.

The "verify.sh" has to be changed accordingly when marked with square brackets "[...]" for cases like Gitlab instance domain, username, e-mail address, etc..
   --> likewise in secuer_ceremony_access/.gitlab-ci.yml

The numeration of "curve_.txt" and "proof_.txt" should be done in a way such that the lexicographical ordering is also the ordering by creation time e.g., by binary numbers. Otherwise the protocol could potentially break.

Use the SIKE parameters 434 from the provided SECUER tools e.g., prove_434, since there are execution problems with the other parameters.