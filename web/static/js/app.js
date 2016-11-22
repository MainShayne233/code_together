const page_name_field = document.getElementById('page-name')
const page_name       = page_name_field ? page_name_field.value : null

switch(page_name) {
  case 'code_room':
    require('./code_room.js')
    break
  case 'new':
    require('./new.js')
    break  
}
