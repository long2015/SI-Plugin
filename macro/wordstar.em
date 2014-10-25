// Wordstar Emulation

/* 
	This macro creates a secondary key mapping which maps 
	keys for a WordStar like emulation, used after the initial
	Ctrl+K and Ctrl+Q keystrokes.

	For example, the user presses Ctrl+K, followed by "d" 
	to run the "Cut Line" command.
	
	Instructions:

	1. Add this macro to a .EM file and add it to 
	   your project.
	
	2. Use the Key Assignments command to map this macro 
	   to Ctrl+K.  The macro name "CtrlK" will show up in the list
	   of commands.

	3. Now you can type Ctrl+K, followed by another key
	   to invoke either "Cut Line" or "Paste Line".  These
	   two commands were picked by random.  You could add
	   what ever key combinations and commands you want.

	The same process applies to the Ctrl_Q macro function also.
*/


macro Ctrl_K() {
    ch = getkey();
    while (ch > 31) {
        ch = ch - 32;
    }

    if (ch <= 16) { // a - p
        if (ch <= 8) { // a - h
            if (ch <= 4) { // a - d
                if (ch <= 2) { // a - b
                    if (ch <= 1) { // a
                    } else { // b
                    }
                } else { // c - d
                    if (ch <= 3) { // c
                        copy()
                    } else { // d
                    	cut_line()
                    }
                }
            } else { // e - h
                if (ch <= 6) { // e - f
                    if (ch <= 5) { // e
                    } else { // f
                    }
                } else { // g - h
                    if (ch <= 7) { // g
                    } else { // h
                    }
                }
            }
        } else { // i - p
            if (ch <= 12) { // i - l
                if (ch <= 10) { // i - j
                    if (ch <= 9) { // i
                    	indent_right()
                    } else { // j
                    }
                } else { // k - l
                    if (ch <= 11) { // k
                    	key_assignments()
                    } else { // l
                    	copy_line()
                    }
                }
            } else { // m - p
                if (ch <= 14) { // m - n
                    if (ch <= 13) { // m
                    	start_recording()
                    } else { // n
                    }
                } else { // o - p
                    if (ch <= 15) { // o
                    } else { // p
                    }
                }
            }
        }
    } else { // q - z
        if (ch <= 24) { // q - x
            if (ch <= 20) { // q - t
                if (ch <= 18) { // q - r
                    if (ch <= 17) { // q
                    } else { // r
                    }
                } else { // s - t
                    if (ch <= 19) { // s
                    } else { // t
                    }
                }
            } else { // u - x
                if (ch <= 22) { // u - v
                    if (ch <= 21) { // u
               		 	indent_left()
                    } else { // v
                    	paste()
                    }
                } else { // w - x
                    if (ch <= 23) { // w
                    	save_selection()
                    } else { // x
                    }
                }
            }
        } else { // y - z
            if (ch <= 25) { // y
            } else { // z
            }
        }
    }
} // ctrlk



macro Ctrl_Q() {
    ch = getkey();
    while (ch > 31) {
        ch = ch - 32;
    }

    if (ch <= 16) { // a - p
        if (ch <= 8) { // a - h
            if (ch <= 4) { // a - d
                if (ch <= 2) { // a - b
                    if (ch <= 1) { // a
                    	replace()
                    } else { // b
                    }
                } else { // c - d
                    if (ch <= 3) { // c
                        bottom_of_file()
                    } else { // d
                    	end_of_line()
                    }
                }
            } else { // e - h
                if (ch <= 6) { // e - f
                    if (ch <= 5) { // e
                    } else { // f
                    	search()
                    }
                } else { // g - h
                    if (ch <= 7) { // g
                    } else { // h
                    }
                }
            }
        } else { // i - p
            if (ch <= 12) { // i - l
                if (ch <= 10) { // i - j
                    if (ch <= 9) { // i
                    } else { // j
                    }
                } else { // k - l
                    if (ch <= 11) { // k
                    } else { // l
                    }
                }
            } else { // m - p
                if (ch <= 14) { // m - n
                    if (ch <= 13) { // m
                    } else { // n
                    	go_to_line()
                    }
                } else { // o - p
                    if (ch <= 15) { // o
                    } else { // p
                    }
                }
            }
        }
    } else { // q - z
        if (ch <= 24) { // q - x
            if (ch <= 20) { // q - t
                if (ch <= 18) { // q - r
                    if (ch <= 17) { // q
                    } else { // r
                    	top_of_file()
                    }
                } else { // s - t
                    if (ch <= 19) { // s
                    	beginning_of_line()
                    } else { // t
                    }
                }
            } else { // u - x
                if (ch <= 22) { // u - v
                    if (ch <= 21) { // u
                    } else { // v
                    }
                } else { // w - x
                    if (ch <= 23) { // w
                    } else { // x
                    }
                }
            }
        } else { // y - z
            if (ch <= 25) { // y
            } else { // z
            }
        }
    }
} // end of ctrlq



