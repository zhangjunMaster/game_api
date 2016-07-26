today = new Date()
year = today.getFullYear()
month = today.getMonth()
day = today.getDate()

#time format
day = {
  yday: '' + year + month + (day - 1),
  tday: '' + year + month + day
}


module.exports = day