#!/usr/bin/env bash

set -eu

SELF=$0
IMG_PATH=
OUT_PREFIX=""
OUT_DIR=
CROP_WIDTH=256
CROP_HEIGHT=256
CONVERT=convert

error()
{
  >&2 echo $@
}

usage()
{
  error $SELF -f IMAGE_FILE_PATH -d OUTPUT_DIR [-x CROP_WIDTH] [-y CROP_HEIGHT] [-p OUTPUT_PREFIX]
  exit 1
}

is_integer()
{
  [[ "$1" =~ ^[0-9]+$ ]]
}

while getopts "x:y:f:p:d:h" FLAG; do
  case $FLAG in
    x)
      CROP_WIDTH=$OPTARG
      is_integer $CROP_WIDTH || usage
      ;;
    y)
      CROP_HEIGHT=$OPTARG
      is_integer $CROP_HEIGHT || usage
      ;;
    f)
      IMG_PATH=$OPTARG
      ;;
    p)
      OUT_PREFIX=$OPTARG
      ;;
    d)
      OUT_DIR=$OPTARG
      ;;
    h)
      usage
      ;;
    *)
      usage
      ;;
  esac
done

CROP_DIM="${CROP_WIDTH}x${CROP_HEIGHT}"

if [ ! -x $(which ${CONVERT}) ]; then
  error "'convert' command don't exist. Please install ImageMagick."
  exit 1
fi

if [ ! -f $IMG_PATH ]; then
  error "Please specify a image file path"
  exit 1
fi

if [ "$OUT_DIR" != "" ]; then
  mkdir -p $OUT_DIR
  OUT_DIR="${OUT_DIR}/"
fi

OUT_SUFFIX=${IMG_PATH##*.}

$CONVERT $IMG_PATH -crop $CROP_DIM -set filename:tile "%[fx:page.x/${CROP_WIDTH}]_%[fx:page.y/${CROP_HEIGHT}]" +repage +adjoin "${OUT_DIR}${OUT_PREFIX}%[filename:tile].${OUT_SUFFIX}"
