#!/bin/bash

# default values
separator=";"
show_foreign=false
speak=false
show=true
total_words=0
declare -a words_native # native words
declare -a words_foreign # foreign words

# help
display_help() {
    echo ""
    echo "$(tput bold)FLASHCARDS$(tput sgr0) - learn a language with a smile :)"
    echo "         by default, the program shows the word in the native language and the user enters the word in a foreign language"
    echo "         using the appropriate switches you can modify the default settings"
    echo "         you can provide a file with words in the format native_word<separator>foreign_word"
    echo "         in the absence of an input file, words will be loaded through standard input"
    echo ""
    echo "$(tput bold)SYNTAX$(tput sgr0)"
    echo "  $0 [-h] [-s 'separator'] [-f] [-b] [-o] [<input_file_name>]"
    echo "      -h              Display help"
    echo "      -s 'separator'  Define your own separator (default ';')" # variable separator = what is on the input
    echo "      -f              Show foreign words" # variable show_foreign = true
    echo "      -b              Speak words along with display" # variable speak = true, show = true
    echo "      -o              Only speak words, without display" # variable speak = true, show = false
    echo ""
    echo "$(tput bold)ATTENTION$(tput sgr0)"
    echo "Please use '_' instead of spaces for multi-part definitions"
    exit 0
}

# processing switches
while getopts ":hs:fbo" opt; do
    case ${opt} in
        h )
            display_help
            ;;
        s )
            separator="$OPTARG"
            ;;
        f )
            show_foreign=true
            ;;
        b )
            speak=true
            ;;
        o )
            show=false
            speak=true
            ;;
        \? )
            echo "Unknown option: $OPTARG" 1>&2
            exit 1
            ;;
        : )
            echo "Error: $OPTARG requires an argument" 1>&2
            exit 1
            ;;
    esac
done
shift $((OPTIND -1))

if (($# > 0))
then
    # read words from a file
    for file in $@
    do
        for line in $(cat $file)
        do
            word_native=$(echo $line | cut -d "$separator" -f 1)
            word_foreign=$(echo $line | cut -d "$separator" -f 2)
            words_native+=($word_native)
            words_foreign+=($word_foreign)
            total_words=$(($total_words+1))
        done    
    done
else
    # read words from STDIN
    echo "Enter the number of words you want to input: "
    read total_words
    echo "Line by line, enter the words in the format native_word"$separator"foreign_word"
    for ((i=0; i<$total_words; i=i+1))
    do
        read line
        word_native=$(echo $line | cut -d "$separator" -f 1)
        word_foreign=$(echo $line | cut -d "$separator" -f 2)
        words_native+=($word_native)
        words_foreign+=($word_foreign)
    done
fi


main ()
{
    clear
    correct=0
    declare -a queue # array for drawing word indexes
    for ((i=0; i<total_words; i++))
    do
        queue+=($i)
    done

    if $show_foreign
    then 
            # display in a foreign language
            echo "I will now display words in a foreign language, enter words in the native language"
            echo "At the end, I will display your score, if you want to end the game earlier, instead of a word type "q""
            echo "Total number of words: $total_words"
            sleep 7
            for((i=5; i>1; i=i-1))
            do
                clear
                echo $i
                sleep 1
            done
            clear
            echo "START"
            sleep 1
            while [ ${#queue[@]} -gt 0 ]
            do
                i=$((RANDOM % ${#queue[@]}))
                current_index=${queue[$i]}
                queue=("${queue[@]:0:$i}" "${queue[@]:$((i + 1))}") # remove the handled index from the word choice queue
                clear
                if $show
                then
                    echo ${words_foreign["$current_index"]}
                fi
                if $speak
                then
                    say ${words_foreign["$current_index"]}
                fi
                read current_word    
                if [[ $current_word == "q" ]]
                then
                    # end of the game
                    break    
                elif [[ $current_word == ${words_native["$current_index"]} ]]
                then
                    correct=$(($correct+1))
                    echo -e "$(tput bold)$(tput setaf 2)Good answer!$(tput sgr0)"
                    sleep 2
                else
                    echo -e "$(tput bold)$(tput setaf 1)Unfortunately not this time, the correct answer is: ${words_native["$current_index"]}$(tput sgr0)"
                    sleep 4
                fi
            done
    else
            # display in the native language
            echo "I will now display words in the native language, enter words in a foreign language"
            echo "At the end, I will display your score, if you want to end the game earlier, instead of a word type "q""
            echo "Total number of words: $total_words"
            sleep 7
            for((i=5;i>0;i=i-1))
            do
                clear
                echo $i
                sleep 1
            done
            clear
            echo "START"
            sleep 2
            while [ ${#queue[@]} -gt 0 ]
            do
                i=$((RANDOM % ${#queue[@]}))
                current_index=${queue[$i]}
                queue=("${queue[@]:0:$i}" "${queue[@]:$((i + 1))}") # remove the handled index from the word choice queue
                clear
                if $show
                then
                    echo ${words_native["$current_index"]}
                fi
                if $speak
                then
                    say ${words_native["$current_index"]}
                fi
                read current_word
                if [[ $current_word == "q" ]]
                then
                    # end of the game
                    break
                elif [[ $current_word == ${words_foreign["$current_index"]} ]]
                then
                    correct=$(($correct+1))
                    echo -e "$(tput bold)$(tput setaf 2)Good answer!$(tput sgr0)"
                    sleep 2
                else
                    echo -e "$(tput bold)$(tput setaf 1)Unfortunately not this time, the correct answer is: ${words_foreign["$current_index"]}$(tput sgr0)"
                    sleep 4
                    
                fi
            done
    fi
    clear         
    percentage=$(echo "scale=2; ($correct/$total_words)*100" | bc) # bc function allowing the use of float numbers
    wrong=$(($total_words-$correct))
    if (( $(echo "$percentage > 50.00" | bc -l) ))
    then
        echo -e "$(tput bold)$(tput setaf 2)Great score!$(tput sgr0)"
    else
        echo -e "$(tput bold)$(tput setaf 1)You still need to study :($(tput sgr0)"
    fi
    echo "Number of correct answers: $correct"
    echo "Number of wrong answers: $wrong"
    echo "Your percentage score: $percentage %"
    echo ""
    echo "Do you want to play again?"
    echo "If yes - press "r" and enter"
    echo "If no - press enter"
    read again
    if [[ $again == "r" ]]
    then
        main
    fi
}

main
