#!/bin/bash

# domyslne wartosci
separator=";"
show_foreign=false
speak=false
show=true
total_words=0
correct=0
declare -a words_native # slowka rodzime
declare -a words_foreign # slowa w jezyku obcym

# pomoc
display_help() {
    echo ""
    echo "FISZKI - ucz się języka z uśmiechem :)"
    echo "         domyślnie program pokazuje słowo w języku rodzimym i uzytkownik wpisuje słowo w języku obcym"
    echo "         za pomocą odpowiednich przełączników mozesz modyfikować ustawienia domyślne"
    echo "         mozesz podać plik ze słówkami w formacie słowo_rodzime[separator]słowo_obce"
    echo "         w przypadku braku pliku wejściowego, słówka zostaną wczytane poprzez standardowe wejście"
    echo ""
    echo "SKŁADNIA"
    echo "  $0 [-h] [-s separator] [-f] [-b] [-o] [<nazwa_pliku_wejsciowego>]"
    echo "      -h              Wyświetl pomoc"
    echo "      -s separator    Zdefiniuj własny separator (domyślnie ':')" # zmienna separator = to co na wejsciu
    echo "      -f              Pokazuj obce słowa" # zmienna show_foreign = true
    echo "      -b              Wypowiadaj słowa wraz z wyświetleniem" # zmienna speak = true, show = true
    echo "      -o              Tylko wypowiadaj słowa, bez wyświetlenia" # zmienna speak = true, show = false
    exit 0
}

# przetwarzanie przelacznikow
while getopts ":hs:fcn" opt; do
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
            echo "Nieznana opcja: $OPTARG" 1>&2
            exit 1
            ;;
        : )
            echo "Błąd: $OPTARG wymagany argument" 1>&2
            exit 1
            ;;
    esac
done
shift $((OPTIND -1))

if (($# > 0))
then
    # odczytuj slowka z pliku
    for file in $@
    do
        for line in $(cat $file)
        do
            word_native=$(echo $line | cut -d "$separator" -f 1)
            word_foreign=$(echo $line | cut -d "$separator" -f 2)
            words_native+=($word_native)
            words_foreign+=($word_foreign)
            total_words+=(1)
        done    
    done
else
    # odczytuj slowka z STDIN
    echo "Podaj ilość słówek, które chcesz wprowadzić: "
    read total_words
    echo "Podawaj linijka po linijce słówka w formacie słowo_rodzime"$separator"słowo_obce"
    for ((i=0; i<$total_words; i=i+1))
    do
        read line
        word_native=$(echo $line | cut -d "$separator" -f 1)
        word_foreign=$(echo $line | cut -d "$separator" -f 2)
        words_native+=($word_native)
        words_foreign+=($word_foreign)
        total_words+=(1)
    done
fi


main ()
{
    for ((i=0; i<$total_words; i=i+1))
    do
        if $show_foreign
        then 
            # wyświetlaj w obcym języku
            echo "Będę teraz wyświetlał słowa w obcym języku, wpisuj słowa w języku rodzimym"
            echo "Na końcu wyświetlę Twój wynik, jeśli chcesz zakończyć grę szybciej, zamiast słowa wpisz "q""
            echo $words_foreign[$i]
            read current_word
            if [[$current_word=="q"]]
            then
                # koniec gry
                break
            elif [[$current_word==$word_native[$i]]]
                correct+=(1)
                echo "Dobra odpowiedź!"
            else
                echo "Niestety nie tym razem, poprawna odpowiedź to: $words_native[$i]"
            fi
        else
            # wyswietlaj w rodzimym jezyku
            echo "Będę teraz wyświetlał słowa w rodzimym języku, wpisuj słowa w języku obcym"
            echo "Na końcu wyświetlę Twój wynik, jeśli chcesz zakończyć grę szybciej, zamiast słowa wpisz "q""
            echo $words_foreign[$i]
            read current_word
            if [[$current_word=="q"]]
            then
                # koniec gry
                break
            elif [[$current_word==$word_foreign[$i]]]
                correct+=(1)
                echo "Dobra odpowiedź!"
            else
                echo "Niestety nie tym razem, poprawna odpowiedź to: $words_foreign[$i]"
            fi
        fi
    done
    percentage=$((($correct/$total_words)*100))
    wrong=$(($total_words-$correct))
    if (($percentage>50))
    then
        echo "Super wynik!"
    else
        echo "Musisz się jeszcze pouczyć :("
    fi
    echo "Liczba poprawnych odpowiedzi: $correct"
    echo "Liczba błędnych odpowiedzi: $wrong" 
    echo "Twój wynik procentowy: $percentage %"
}

main


# losowe wyswietlanie slowek
# wypowiadanie slowek