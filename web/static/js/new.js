const form       = document.getElementById("new-code-room-form")
const form_error = document.getElementById('new-code-room-error')

form.addEventListener('submit', (event) => {
  event.preventDefault()
  if (basic_validations()) validate_name()
})

function basic_validations() {
  const name = form.elements['code_room_name'].value
  if (name.trim() === '') {
    show_error('Code room name cannot be blank')
    return false
  }
  return true
}

function validate_name() {
  const name = form.elements['code_room_name'].value
  const XHR = new XMLHttpRequest()
  XHR.onreadystatechange = () => {
    if (XHR.readyState === 4 && XHR.status === 200) {
      const response = JSON.parse(XHR.responseText)
      response.error ? show_error(response.error) : form.submit()
    }
  }
  XHR.open("GET", `/api/code_rooms/validate_name/${name}`, true)
  XHR.send(null)
}

function show_error(error) {
  form_error.innerHTML = error
}
