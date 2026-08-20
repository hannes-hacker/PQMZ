#!/bin/bash
# This is the execution script according to the CI pipeline stage "verification".

# Configuration of the Gitlab repository for secure storage.
cd secuer_ceremony_storage
git config --global user.email "[GITLAB INSTANCE EMAIL]"
git config --global user.name "[GITLAB INSTANCE USERNAME]"
git remote set-url origin https://oauth2:${AUTOMATION_ACCESS_TOKEN}@[GITLAB INSTANCE DOMAIN]/[GITLAB INSTANCE USERNAME]/secuer_ceremony_storage.git
cd ..

# Configuration of the access GitHub repository to initialize to the branch.
# the pull request is based on.
cd secuer_ceremony_access
git config --global user.email "[GITHUB EMAIL]"
git config --global user.name "[GITHUB USERNAME]"
git remote set-url origin https://oauth2:${ACCESS_GITHUB_TOKEN}@github.com/[GITHUB USERNAME]/secuer_ceremony_access.git
git checkout $CI_EXTERNAL_PULL_REQUEST_SOURCE_BRANCH_NAME
git pull

# Saving necessary information about the new additions.
curve_additions=$(ls c-impl/new_additions | head -n1)
proof_additions=$(ls c-impl/new_additions | tail -n1)
number_additions=$(ls c-impl/new_additions -1 | wc -l)
cd ..

# Execution of the script contents should only be done when 2 new additions have been provided.
if [ $number_additions -eq 2 ]; then

  # Building a reliable instance of the verification application (SECUER-PoK tools).
  cd secuer_ceremony_storage/c-impl
  make
  #make test
  cd ../..

  # Verification of the provided proof.
  ./secuer_ceremony_storage/c-impl/verify_434 < secuer_ceremony_access/c-impl/new_additions/$proof_additions > secuer_ceremony_storage/testcurve.txt

  # Check if the provided curve file is equal to the result of the reliable verification.
  input_file="secuer_ceremony_access/c-impl/new_additions/$curve_additions"
  input_hash=$(sha256sum "$input_file" | head -c64)
  reference_file="secuer_ceremony_storage/testcurve.txt"
  reference_hash=$(sha256sum "$reference_file" | head -c64)
  rm secuer_ceremony_storage/testcurve.txt
  if [ ! $input_hash = $reference_hash ]; then
    exit 1
  fi

  # Add the verified additions to the respective directories.
  mv secuer_ceremony_access/c-impl/new_additions/proof* secuer_ceremony_access/c-impl/proofs
  mv secuer_ceremony_access/c-impl/new_additions/curve* secuer_ceremony_access/c-impl/curves

  # Update the reference hashes for the verified proofs and curves.
  
  rm secuer_ceremony_storage/hashes/curves.txt
  rm secuer_ceremony_storage/hashes/proofs.txt

  cd secuer_ceremony_access
  sha256sum c-impl/proofs/* | sha256sum | head -c64 > /builds/[GITLAB INSTANCE USERNAME]/secuer_ceremony_access/secuer_ceremony_storage/hashes/proofs.txt
  sha256sum c-impl/curves/* | sha256sum | head -c64 > /builds/[GITLAB INSTANCE USERNAME]/secuer_ceremony_access/secuer_ceremony_storage/hashes/curves.txt
  
  cd ..
  cd secuer_ceremony_storage

  # Pushing the new state of the Gitlab repository for secure storage.
  git add --all
  git commit -m "$curve_additions and $proof_additions have been successfully appended!"
  git push --all

  # Pushing the new state of the pull request's branch of the GitHub repository.
  cd ..
  cd secuer_ceremony_access
  git add --all
  git commit -m "new_additions have been cleared!"
  git push -u origin $CI_EXTERNAL_PULL_REQUEST_SOURCE_BRANCH_NAME

  # Merging the added, verified state of the GitHub repository to the main (default) branch.
  git checkout main
  git pull
  git merge $CI_EXTERNAL_PULL_REQUEST_SOURCE_BRANCH_NAME
  git push -u origin main
fi