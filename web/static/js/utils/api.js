import axios from 'axios'

export function getCurrentUser() {
  return new Promise((res, rej) => {
    axios.get('/api/session/current_user').then(response => {
      const { username } = response.data
      res(username)
    })
  })
}

export function createNewUser(username) {
  return axios.post('/api/session/create', {
    username: username,
  })
}

export function createCoderoom(coderoom) {
  return axios.post('/api/coderooms/create', coderoom)
}

export function getCoderoom(coderoom) {
  const [field] = Object.keys(coderoom)
  const url = `/api/coderooms/?${field}=${coderoom[field]}`
  return axios.get(url)
}

export function startCoderoom(coderoom) {
  return axios.post('/api/coderooms/start', coderoom)
}

export function getPublicCoderooms() {
  return new Promise((res, rej) => {
    axios.get('/api/coderooms/all/public').then(response => {
      res(response.data.coderooms)
    })
  })
}
