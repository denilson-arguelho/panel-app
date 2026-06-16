
function speechQueue (speech, texts, lang, options, index) {
  return new Promise((resolve, reject) => {
    if (texts.length === 0 || index >= texts.length) {
      resolve()
      return
    }

    let text = texts[index]
    speech(text, lang, options).then(() => {
      speechQueue(speech, texts, lang, options, index + 1)
        .then(resolve)
        .catch(reject)
    }, reject)
  })
}

export default {

  speech (text, lang, options = {}) {
    return new Promise((resolve, reject) => {
      const msg = new SpeechSynthesisUtterance()
      msg.text = text
      msg.lang = (lang || '').replace('_', '-').toLowerCase()
      
      // Apply voice options
      if (options.rate) msg.rate = options.rate
      if (options.pitch) msg.pitch = options.pitch
      if (options.volume) msg.volume = options.volume
      
      // Select voice based on gender preference
      if (options.voiceGender) {
        const voices = window.speechSynthesis.getVoices()
        const langCode = msg.lang.split('-')[0]
        const preferredVoice = voices.find(v => {
          const voiceLang = v.lang.split('-')[0]
          if (voiceLang !== langCode) return false
          
          if (options.voiceGender === 'male') {
            return v.name.toLowerCase().includes('male') || 
                   v.name.toLowerCase().includes('homem') ||
                   v.name.toLowerCase().includes('man')
          } else {
            return v.name.toLowerCase().includes('female') || 
                   v.name.toLowerCase().includes('mulher') ||
                   v.name.toLowerCase().includes('woman')
          }
        })
        
        if (preferredVoice) {
          msg.voice = preferredVoice
        }
      }

      msg.onerror = reject
      msg.onend = resolve

      window.speechSynthesis.speak(msg)
    })
  },

  speechAll (texts, lang, options = {}) {
    return speechQueue(this.speech, texts, lang, options, 0)
  },

  getAvailableVoices () {
    return window.speechSynthesis.getVoices()
  },

  cancelSpeech () {
    window.speechSynthesis.cancel()
  }
}
