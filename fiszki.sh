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
            echo $words_foreign[$i]
        else

        fi
    done
}

# main "$@"

# losowe wyswietlanie slowek
# domyslnie: skrypt pokazuje slowo w jezyku rodzimym i uzytkownik wpisuje obce 
# lub odwrotnie
# informacja o poprawnosci
# za pomoca przelacznika mozna wypowiedziec slowo i wyswietlone lub bez
# na koncu liczba poprawnych odpowiedzi, blednych i wynik w % 

# co zrobic
# odpowiednie wyswietlanie slowek
# wypowiadanie slowek
#essunia balety