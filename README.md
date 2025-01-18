# Gir [TESTING]
A Git wrapper combining Oh Shit, Git!?! and Gum
## What is this?
This is the direct testing branch of Gir. It currently has no practical way to install. Every change gets pushed to this repo.
## No, I meant what is this project?
Oh, right!
With the elements of [Gum](https://github.com/charmbracelet/gum) and [Oh Shit, Git!?!](https://ohshitgit.com/), I made an attempt at making a simple Git wrapper that can combine the two together.

There's not much else to say.......except that the Setup...at least works

## Installing the Testing branch
### ⚠️ BEFORE YOU PROCEED!!!!
You are using this branch at your OWN RISK. By installing the testing branch, YOU agree to NOT blame me for any fuck-ups occuring to your Git repo. Remember, this is not a way to "get the cool updates faster", this is the CONSTRUCTION site.
### you have been warned.
If you still want to install, proceed as followed:
1. **Clone the repository**
```bash
git clone https://github.com/Icycoide/Gir
```
Make sure you remember where you put the repository!

2. **Switch to testing branch**
```bash
git checkout testing
```

3. **Create a symlink to the file in the repository**
```bash
sudo ln -s /path/to/git/repository/main.sh /path/to/destination/for/binary/gir
```

## Updating
Updating is as simple as going to the source repository and running the following (assuming you didn't fuck up anything, in which case you'd have to reset to remote):
```bash
git pull
```

This is licensed under the MIT license
