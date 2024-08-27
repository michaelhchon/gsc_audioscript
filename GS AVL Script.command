#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Make sure Audacity is running and that mod-script-pipe is enabled
before running this script.
"""

import os
import sys
import time
import json

from pynput.keyboard import Key, Listener
from datetime import date


# Open Audacity; 10 second delay to ensure it is fully loaded before giving script user control
os.system("open /Applications/Audacity.app")
time.sleep(10)


"""
Lines 33 to 97 set up pipelines to allow us to interact with Audacity outside of the app
DO NOT TOUCH
"""






# Platform specific file name and file path.
# PATH is the location of files to be imported / exported.

PATH = "/Users/goodstewards/Library/CloudStorage/GoogleDrive-stewardssogood@gmail.com/.shortcut-targets-by-id/1lGE_0BZRjIAQ2qxxG7azMCqfUjGZg8Us/Recordings"


# Platform specific constants
if sys.platform == 'win32':
    print("recording-test.py, running on windows")
    PIPE_TO_AUDACITY = '\\\\.\\pipe\\ToSrvPipe'
    PIPE_FROM_AUDACITY = '\\\\.\\pipe\\FromSrvPipe'
    EOL = '\r\n\0'
else:
    print("recording-test.py, running on linux or mac")
    PIPE_TO_AUDACITY = '/tmp/audacity_script_pipe.to.' + str(os.getuid())
    PIPE_FROM_AUDACITY = '/tmp/audacity_script_pipe.from.' + str(os.getuid())
    EOL = '\n'


print("Write to  \"" + PIPE_TO_AUDACITY +"\"")
if not os.path.exists(PIPE_TO_AUDACITY):
    print(""" ..does not exist.
    Ensure Audacity is running with mod-script-pipe.""")
    sys.exit()

print("Read from \"" + PIPE_FROM_AUDACITY +"\"")
if not os.path.exists(PIPE_FROM_AUDACITY):
    print(""" ..does not exist.
    Ensure Audacity is running with mod-script-pipe.""")
    sys.exit()

print("-- Both pipes exist.  Good.")

TOPIPE = open(PIPE_TO_AUDACITY, 'w')
print("-- File to write to has been opened")
FROMPIPE = open(PIPE_FROM_AUDACITY, 'r')
print("-- File to read from has now been opened too\r\n")


def send_command(command):
    """Send a command to Audacity."""
    print("Send: >>> "+command)
    TOPIPE.write(command + EOL)
    TOPIPE.flush()


def get_response():
    """Get response from Audacity."""
    line = FROMPIPE.readline()
    result = ""
    while True:
        result += line
        line = FROMPIPE.readline()
        # print(f"Line read: [{line}]")
        if line == '\n':
            return result


def do_command(command):
    """Do the command. Return the response."""
    send_command(command)
    # time.sleep(0.1) # may be required on slow machines
    response = get_response()
    print("Rcvd: <<< " + response)
    return response






"""
Start of GSC Script
"""


today = str(date.today())
success = False # flag for audio export success

def play_record(key):
    """Import track and record to new track.
    Note that a stop command is not required as playback will stop at end of selection.
    """
    global success

    try: 
        if key.char == 'q':
            print("\nStart was pressed\n")
            do_command("Record2ndChoice")

        elif key.char == "p":
            print("\nStop was pressed\n")
            do_command("Stop")
            success = True
            return False

        elif key.char == "c":
            print("\nClear was pressed\n")
            do_command("Stop")
            do_command("SelectAll")
            do_command("RemoveTracks")

        elif key.char == "h":
            print("\nInputs:")
            print("q - start recording")
            print("p - stop recording, save, and upload")
            print("c - clear recording")
            print("h - help")
            print("esc - fail safe exit\n")

    except AttributeError:
        # Escape key is the fail safe
        if key == Key.esc:
            do_command("Stop")
            do_command("SelectAll")
            do_command("RemoveTracks")
            return False
        pass

"""
Saves current audio track and clears Audacity for next track

"BUG": Audacity script command "Export2" takes 2 arguments:
1. filename(path)
2. NumChannels(1 for mono, 2 for stereo)

However, if your filename or path has a whitespace in it, the command will take everything before the whitespace
as parameter 1 and everything after  it as parameter 2

This leads to a failed command...could not find a solution, but found a temporary workaround:

Google Drive shortcut sometimes has paths saved in cache without any whitespaces

Luckily for us, we have one so I used that path to save our files onto Google Drive
If you take a look at the PATH variable in line 36, it's a weird path with an address as opposed to high level white space path

We can move the files later using "os" commands as terminal doesn't care about whitespaces in paths
"""
def export(filename):
    """Export the new track, and deleted both tracks."""
    do_command("Select: mode=Set")
    do_command("SelTrackStartToEnd")
    do_command(f"Export2: Filename={os.path.join(PATH, filename)} NumChannels=2")
    do_command("SelectAll")
    do_command("RemoveTracks")


"""
Calls play_record() and exports when finished
Uses listener instead of while loop input to track keyboard inputs
Logic is that keyboard listener can hear anywhere and doesn't require new line input
"""
def do_one_file(filename):
    """Run test with one input file only."""
    global success

    with Listener(on_press = play_record) as listener:
        listener.join()

    if success:
        export(filename)
        success = False


def music_pt_1():
    print("\nREADY FOR MUSIC PT 1\n")
    do_one_file("music_pt_1.mp3")

    file_name = PATH + "/music_pt_1.mp3"
    if os.path.exists(file_name):
        os.rename(file_name, PATH + "/" + today + " GS Music Pt 1.mp3")


def music_pt_2():
    print("\nREADY FOR MUSIC PT 2\n")
    do_one_file("music_pt_2.mp3")

    file_name = PATH + "/music_pt_2.mp3"
    if os.path.exists(file_name):
        os.rename(file_name, PATH + "/" + today + " GS Music Pt 2.mp3")


def sermon():
    print("\nREADY FOR SERMON\n")
    do_one_file("sermon.mp3")

    file_name = PATH + "/sermon.mp3"
    if os.path.exists(file_name):
        os.rename(file_name, PATH + "/gs " + today + ".mp3")


# MAIN
def starter():

    print("Please make sure that \'Export Audio\' is set to:")
    print("Format: MP3 Files")
    print("Quality: Insane, 320 kbps\n")

    print("Record: ")
    print("Inputs:")
    print("1 - music pt 1")
    print("2 - sermon")
    print("3 - music pt 2")
    print("a - all three\n")

    res = input()
    while True:
        if res == "a":
            music_pt_1()
            sermon()
            music_pt_2()
            break
        elif res == "1":
            music_pt_1()
            break
        elif res == "2":
            sermon()
            break
        elif res == "3":
            music_pt_2()
            break

        res = input()

    # Close Audacity? Not sure considering you get prompted to save when exiting


starter()


"""
LINKS?
No easy way to get share links; may have to make a VERY manual script that clicks around the browser
Google Drive is supposedly having keyboard shortcuts in August and maybe we can work with that?
"""
