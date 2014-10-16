angular.module 'hello'
.filter 'kern', ($sce) ->
  wrap = (tag, input) -> "<#{tag}>#{input}</#{tag}>"

  (input, fill, length, wrapperTag) ->
    arr          = input.toString().split('')
    inputLength  = arr.length
    length      ?= 2
    diff         = length - inputLength
    fill        ?= '0'

    if wrapperTag
      fill = wrap(wrapperTag, fill)
      tmpArr = []
      for i in [0..inputLength-1]
        tmpArr.push wrap(wrapperTag, arr[i])

      arr = tmpArr

    if diff > 0
      for i in [0..diff - 1]
        arr.unshift fill

    return arr.join('') unless wrapperTag
    return $sce.trustAsHtml(arr.join('')) if wrapperTag
