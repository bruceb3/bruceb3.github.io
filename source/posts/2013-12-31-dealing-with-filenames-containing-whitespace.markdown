---
title: Dealing With File Names Containing Whitespace
layout: post
---

# What is the problem?

File names containing spaces are generally painful to deal with in UNIX from the command line. Say we have a directory with the following two files;

```bash
one
one love
```

These days the shell wildcard expansion is smart enough to give a command the proper file names. So `rm one*` works as expected but as soon as you need to use the find command or any command that is going to read in the file with a space, and pass it to another command there will be trouble.

Here are some examples;

```bash
$ find . -type f | xargs ls -l
ls: love: No such file or directory
-rw-r--r--  1 bruce  staff  0 31 Dec 13:58 ./one
-rw-r--r--  1 bruce  staff  0 31 Dec 13:58 ./one
```

# What exactly is going on?

Running the find command alone, we get

```bash
$ find . -type f
./one
./one love
```

xargs will run `ls -l` with the output of the command concatenated onto a single line,  which looks like this; `ls -l one one love`. The ls command will be run from the shell with 3 args and as there isn't a file called love, ls complains with the error 'No such file or directory'

# A Solution?

Even though this has been an issue for many years, it's common to see housekeeping and backup scripts still failing on file names that contain spaces. On some versions of UNIX, the find and xargs commands have an option to deal with spaces in file names. Use the `-print0` option to the find command and the `-0` option to the xargs command to have xargs use a NULL character as the terminator. This will work on Linux and Mac but not all versions of Solaris and AIX have these options to find and xargs.

Here is an example of using -print0 and -0

```bash
$ find . -type f -print0 | xargs -0 ls -l
-rw-r--r--  1 bruce  staff  0 31 Dec 13:58 ./one
-rw-r--r--  1 bruce  staff  0 31 Dec 13:58 ./one love
$
```

# What to do when using other tools?

Even though there are many options to find that allow you to filter the names of the files, it's still not uncommon to need to add a grep or two into the find-xargs pipeline, at which point the -print0 and -0 nolonger work as needed.

```bash
$ find . -type f -print0 | grep e | xargs -0 ls -l
ls: Binary file (standard input) matches
: No such file or directory
```

Also, how to handle scenarios similar to;

```bash
$ for i in $(ls -1rt | head -n 5); do echo $i; done
one
love
one
```

That ls command above will display the contents of the directory in a single colum order by modification, 

Now at this point, you are probably thinking that it's time to use Ruby or Python, or maybe even Perl but there is a solution. The shell has an internal variable called IFS, which standards for Internal Field Separator. By default the value of this variable will be a space, a tab and a new line character. On a Mac, using the od command we can see the default value.

```bash
$ echo -n "$IFS" | od -t a
0000000   sp  ht  nl
0000003
$
```

Changing the value of IFS changes the way that the shell processes the command options. The goal is to change IFS to something that isn't in the filename but is easy enough to add to the filename. Usually this would be a carriage return, so we need to remove the space and tab characters from the IFS variable. Using sed would probably work but it's far easy to save the current value of the IFS variable and then set it to the carriage return.

```bash
$ origIFS="$IFS"; IFS="^M"; for i in $(ls -1rt | head -n 5); do echo $i; done; IFS="$origIFS"
one love
one
$
```

## What is that "^M" thing?

Control-M is a the representation of carriage return. To enter that command type control-v and then control-m. (Control-v will "quote" the next character that is typed).

## Setting IFS back to the default.

It's very important to set IFS back to the default value as soon as you have finished. Forgetting to do so will result is unexpected behaviour.

## Use Double Quotes

When there is a chance that there will be spaces in the file name, it's important to put double quotes around the variable expansion.

## One More Thing

In the previous example I have the shell command all on one line using semicolons to seperate the commands. Normally scripts wouldn't be written this way. It's perfectly ok to set IFS back to the original value right after the for key word.

```bash
$ origIFS="$IFS"
> IFS=""
> for i in $(ls -1rt | head -n 5)
> do
>         IFS="$origIFS"
>         # use double quotes to stop the expansion of $i becoming to args to echo
>         # or don't reset IFS
>         echo "$i"
> done
> IFS="$origIFS"
```

# To Summarise

Set the IFS variable to be the carriage return and make sure that each file name is piped or expanded by the shell with the new line character intact, which happens by default.

The alert reader will notice that I didn't make any comments about zsh. zsh does have an IFS variable, but of course zsh has additional options and I didn't want to have spend time commenting on those. The sample code in this blog post works on zsh.
