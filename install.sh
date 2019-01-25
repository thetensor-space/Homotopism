# Vars
FILE="$(realpath -s "$0")"              # Full path to this file
DIR="$(dirname $FILE)"                  # Current directory
PKGDIR="$(dirname $DIR)"                # Directory for dependencies
START="${HOME}/.magmarc"                # Magma start file location

# Dependencies and .spec locations
ATTACH1="AttachSpec(\"$DIR/Homotopism.spec\");"
ATTACH2="AttachSpec(\"$PKGDIR/TensorSpace/TensorSpace.spec\");"


echo "Homotopism.spec is in $DIR"


echo "Dependencies will be downloaded to $PKGDIR"


# TensorSpace install/ update
if [ -f "$PKGDIR/TensorSpace/update.sh" ]
then
    echo "Dependencies already installed, updating..."
    sh "$PKGDIR/TensorSpace/update.sh"
else
    echo "Could not find TensorSpace, downloading..."
    cd "$PKGDIR"
    git clone -q https://github.com/algeboy/TensorSpace
fi

echo "Dependencies downloaded."


# Construct Magma start file

if [ -f "$START" ]
then
    echo "Found a Magma start file"
    for A in "$ATTACH1" "$ATTACH2" do
        if grep -Fxq "$A" "$START"
        then
            echo "Already installed"
        else
            echo "$A" >> "$START"
            echo "Successfully installed"
        fi
    done
else
    echo "Creating a Magma start file: $START"
    echo "// Created by an install file for Magma start up." > "$START"
    for A in "$ATTACH1" "$ATTACH2" do
        echo "$A" >> "$START"
    done
    echo "Successfully installed"
fi

