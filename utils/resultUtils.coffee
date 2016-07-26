resultMsgMap =
  1: '成功'
  2: '失败'

getResultMsg = (result, err) ->
  resultMsg = resultMsgMap[result] or '未知错误'
  err = err or resultMsg
  {result, resultMsg, err}

module.exports = {getResultMsg}
