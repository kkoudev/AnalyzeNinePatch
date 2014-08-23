#!/bin/bash

#--------------------------
# 起動引数
#
# 1 : 検索ディレクトリパス
# 2 : 画像ファイルの拡張子
#--------------------------
IMAGE_DIR=$1
IMAGE_EXTENSION=$2

# ファイル数分繰り返し
for IMAGE_FILE in $(echo "$(find ${IMAGE_DIR} -type f -name "*.${IMAGE_EXTENSION}")")
do

    #--------------------------
    # 各種変数情報
    #
    # IMAGE_SIZE       : 画像サイズ (幅x高さ)
    # IMAGE_WIDTH      : 画像幅
    # IMAGE_HEIGHT     : 画像高さ
    # IMAGE_NINE_PATCH : 画像が9-patchの場合は 1
    #--------------------------
    IMAGE_SIZE=$(identify ${IMAGE_FILE} | awk '{print $3}')
    IMAGE_WIDTH=${IMAGE_SIZE%%x*}
    IMAGE_HEIGHT=${IMAGE_SIZE##*x}
    IMAGE_NINE_PATCH=1

    #------------------------
    # 画像の上辺と下辺を確認
    #------------------------

    # 上辺と下辺を処理する
    for y in 0 $((${IMAGE_HEIGHT} - 1))
    do

        # 画像のピクセル情報を取得する
        IMAGE_PIXELS=$(convert ${IMAGE_FILE} -crop ${IMAGE_WIDTH}x1+0+${y} txt:- | sed -E '1d')

        # ピクセル情報分繰り返し
        for PIXEL_INDEX in $(seq ${IMAGE_WIDTH})
        do

            # ピクセル情報を取得する
            IMAGE_PIXEL=$(echo "${IMAGE_PIXELS}" | awk 'NR=='"${PIXEL_INDEX}"'' | awk '{print $4}')

            # 透明か黒以外の場合
            if [ "${IMAGE_PIXEL}" != 'none' -a "${IMAGE_PIXEL}" != 'black' ]; then

                # 9-patch画像以外
                IMAGE_NINE_PATCH=0

                # 処理中断
                break 2

            fi

        done

    done


    # 9-patch画像以外の場合
    if [ ${IMAGE_NINE_PATCH} -eq 0 ]; then

        # 非9-patch画像として出力
        echo "normal image : ${IMAGE_FILE}"

        # 次のファイルへ
        continue

    fi


    #------------------------
    # 画像の左辺と右辺を確認
    #------------------------

    # 左辺と右辺を処理する
    for x in 0 $((${IMAGE_WIDTH} - 1))
    do

        # 画像のピクセル情報を取得する
        IMAGE_PIXELS=$(convert ${IMAGE_FILE} -crop 1x${IMAGE_HEIGHT}+${x}+0 txt:- | sed -E '1d')

        # ピクセル情報分繰り返し
        for PIXEL_INDEX in $(seq ${IMAGE_HEIGHT})
        do

            # ピクセル情報を取得する
            IMAGE_PIXEL=$(echo "${IMAGE_PIXELS}" | awk 'NR=='"${PIXEL_INDEX}"'' | awk '{print $4}')

            # 透明か黒以外の場合
            if [ "${IMAGE_PIXEL}" != 'none' -a "${IMAGE_PIXEL}" != 'black' ]; then

                # 9-patch画像以外
                IMAGE_NINE_PATCH=0

                # 処理中断
                break 2

            fi

        done

    done


    # 9-patch画像の場合
    if [ ${IMAGE_NINE_PATCH} -eq 1 ]; then

        # 9-patch画像として出力
        echo "9-patch image : ${IMAGE_FILE}"

    else

        # 非9-patch画像として出力
        echo "normal image : ${IMAGE_FILE}"

    fi

done
