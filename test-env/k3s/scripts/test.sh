#!/bin/bash


declare -A person=(
    [name]='John'
    [city]='New York'
    [job]='Software Engineer'
)

declare -A person2=(
    [name]='John'
    [city]='New York'
    [job]='Software Engineer'
)

echo "${person[name]}"
echo "${person[city]}"
echo "${person[job]}"

echo "${person2[name]}"
echo "${person2[city]}"
echo "${person2[job]}"



string="(T)his is a (test)"

# Initialize an empty array
values=()

# Use regex to extract values between parentheses
regex="\(([^)]+)\)"
while [[ $string =~ $regex ]]; do
    # Append the extracted value to the array
    values+=("${BASH_REMATCH[1]}")
    # Remove the matched value from the string
    string=${string#*"${BASH_REMATCH[0]}"}
done

# Print the array
echo "${values[@]}"



string="one,two,three,four"
string="one"
# split a comma separated string into an array
IFS=',' read -r -a array <<< "$string"
# print the array
echo "${array[@]}"
echo $IFS


