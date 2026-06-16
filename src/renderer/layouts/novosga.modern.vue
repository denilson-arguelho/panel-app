<template>
  <div class="novosga-modern layout-content" :style="{ 'background-color': color('pageBgColor'), 'color': color('pageFontColor') }">
    <!-- Fullscreen Button (Hidden until hover) -->
    <div class="fullscreen-control" @click="toggleFullscreen" :title="isFullscreen ? 'Sair de Tela Cheia' : 'Tela Cheia'">
      <i class="fa" :class="isFullscreen ? 'fa-compress' : 'fa-expand'"></i>
    </div>

    <!-- Main Grid Layout (Based on User Image) -->
    <div class="main-grid">
      <!-- MAIN CONTENT (LEFT) -->
      <main class="main-content">
        <div class="video-container">
          <iframe
            v-if="isYoutubeUrl(config.themeOptions.videoUrl)"
            :src="getEmbedUrl(config.themeOptions.videoUrl)"
            class="video-player"
            frameborder="0"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
            allowfullscreen>
          </iframe>
          <video v-else-if="config.themeOptions.videoUrl" :src="config.themeOptions.videoUrl" class="video-player" autoplay loop muted></video>
          <div v-else class="no-video">
            <img :src="logoUrl" class="main-logo-placeholder">
          </div>
        </div>
      </main>

      <!-- SIDEBAR (RIGHT) -->
      <aside class="sidebar-right">
        <!-- SIDEBAR HEADER: RELÓGIO -->
        <header class="sidebar-header-section" :style="{ 'background-color': color('clockBgColor'), 'color': color('clockFontColor') }">
          <clock :locale="config.locale" :dateFormat="'date_format'|trans" :fontColor="color('clockFontColor')"></clock>
        </header>

        <!-- SIDEBAR CONTENT: SENHA EM DESTAQUE -->
        <section class="sidebar-content-section" :style="{ 'background-color': color('sidebarBgColor'), 'color': color('sidebarFontColor') }">
          <featured v-if="lastMessage" :message="lastMessage" :fontColor="color('featuredFontColor', 'sidebarFontColor')"></featured>
          <div v-else class="waiting-message">
            {{ 'history.empty'|trans }}
          </div>
        </section>

        <!-- SIDEBAR FOOTER: CLIMA E TEMPO -->
        <footer class="sidebar-footer-section" :style="{ 'background-color': color('footerBgColor'), 'color': color('footerFontColor') }">
          <weather :fontColor="color('footerFontColor')"></weather>
        </footer>
      </aside>

      <!-- MAIN FOOTER (BOTTOM LEFT) -->
      <footer class="main-footer-section" :style="{ 'background-color': color('footerBgColor'), 'color': color('footerFontColor') }">
        <div class="history-wrapper">
          <history
            :messages="messages"
            :fontColorNormal="config.historyFontColorNormal || config.footerFontColorNormal"
            :fontColorPriority="config.historyFontColorPriority || config.footerFontColorPriority">
          </history>
        </div>
      </footer>
    </div>
  </div>
</template>

<script>
  import Clock from '@/components/Clock.vue'
  import Featured from '@/components/Featured.vue'
  import History from '@/components/History.vue'
  import Weather from '@/components/Weather.vue'
  import audio from '@/services/audio'
  import speech from '@/services/speech'

  export default {
    name: 'Modern',
    components: {
      Clock,
      Featured,
      History,
      Weather
    },
    data () {
      return {
        isCalling: false,
        lastMessage: null,
        messageQueue: [],
        isFullscreen: false
      }
    },
    computed: {
      messages () {
        return this.$store.getters.history
      },
      message () {
        return this.$store.getters.message
      },
      config () {
        return this.$store.state.config
      },
      logoUrl () {
        return this.config.themeOptions.logo || 'static/images/logo.png'
      }
    },
    methods: {
      call () {
        this.messageQueue.push(this.message)
        if (!this.isCalling) {
          this.playAudio()
        }
      },
      playAudio () {
        if (this.isCalling || this.messageQueue.length === 0) {
          return
        }
        this.isCalling = true
        this.lastMessage = this.messageQueue.shift()
        
        audio.playAlert(this.config.alert)
          .then(() => {
            if (!this.config.speech) {
              return Promise.resolve()
            }
            let texts = ['Senha']
            this.message.$data.siglaSenha.split('').forEach(char => texts.push(char))
            texts.push(this.message.$data.numeroSenha)
            texts.push(this.message.$data.local)
            texts.push(this.message.$data.numeroLocal)
            
            return speech.speechAll(texts, this.config.locale, {
              voiceGender: this.config.voiceGender || 'female',
              rate: this.config.speechRate || 1,
              pitch: this.config.speechPitch || 1,
              volume: this.config.speechVolume || 1
            })
          })
          .then(() => {
            this.isCalling = false
            this.playAudio()
          })
      },
      toggleFullscreen () {
        if (!document.fullscreenElement) {
          document.documentElement.requestFullscreen().catch(err => {
            console.error(`Error attempting to enable fullscreen: ${err.message}`)
          })
          this.isFullscreen = true
        } else {
          document.exitFullscreen()
          this.isFullscreen = false
        }
      },
      isYoutubeUrl (url) {
        return url && (url.includes('youtube.com') || url.includes('youtu.be'))
      },
      getEmbedUrl (url) {
        if (!url) return ''
        let videoId = ''
        
        if (url.includes('youtube.com/watch?v=')) {
          videoId = url.split('v=')[1].split('&')[0]
        } else if (url.includes('youtu.be/')) {
          videoId = url.split('youtu.be/')[1].split('?')[0]
        }
        
        return `https://www.youtube.com/embed/${videoId}?autoplay=1&mute=1&loop=1&playlist=${videoId}`
      },
      color (prefix, fallback) {
        const peso = this.lastMessage && this.lastMessage.$data ? this.lastMessage.$data.peso : 0
        const suffix = peso > 0 ? 'Priority' : 'Normal'
        return this.config[prefix + suffix] || this.config[(fallback || prefix) + suffix]
      }
    },
    watch: {
      message () {
        this.call()
      }
    },
    mounted () {
      document.addEventListener('fullscreenchange', () => {
        this.isFullscreen = !!document.fullscreenElement
      })
      // Initial message
      if (this.message && this.message.id) {
        this.lastMessage = this.message
      }
    }
  }
</script>

<style lang="sass" scoped>
  .novosga-modern
    position: fixed
    width: 100%
    height: 100%
    overflow: hidden
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif

    .fullscreen-control
      position: fixed
      top: 2vh
      right: 2vh
      z-index: 1000
      opacity: 0
      transition: opacity 0.3s ease
      cursor: pointer
      background-color: rgba(0, 0, 0, 0.5)
      color: white
      width: 6vh
      height: 6vh
      border-radius: 50%
      display: flex
      align-items: center
      justify-content: center
      font-size: 3vh
      
      &:hover
        opacity: 1
        background-color: rgba(0, 0, 0, 0.8)

    &:hover .fullscreen-control
      opacity: 1

    .main-grid
      display: grid
      grid-template-columns: 1fr 30vw
      grid-template-rows: 1fr 20vh
      height: 100vh
      width: 100vw

    .main-content
      grid-column: 1
      grid-row: 1
      background-color: #000
      display: flex
      align-items: center
      justify-content: center
      overflow: hidden

      .video-container
        width: 100%
        height: 100%
        
        .video-player
          width: 100%
          height: 100%
          border: none
        
        .no-video
          width: 100%
          height: 100%
          display: flex
          align-items: center
          justify-content: center
          background: radial-gradient(circle, #222 0%, #000 100%)
          
          .main-logo-placeholder
            max-width: 50%
            max-height: 50%
            opacity: 0.5

    .sidebar-right
      grid-column: 2
      grid-row: 1 / span 2
      display: flex
      flex-direction: column
      border-left: 1px solid rgba(255, 255, 255, 0.1)

      .sidebar-header-section
        height: 20vh
        display: flex
        align-items: center
        justify-content: center
        border-bottom: 1px solid rgba(0, 0, 0, 0.1)
        padding: 2vh

      .sidebar-content-section
        flex: 1
        display: flex
        align-items: center
        justify-content: center
        padding: 2vh
        text-align: center

        .waiting-message
          font-size: 2vw
          opacity: 0.5

      .sidebar-footer-section
        height: 15vh
        display: flex
        align-items: center
        justify-content: center
        border-top: 1px solid rgba(0, 0, 0, 0.1)
        padding: 2vh

    .main-footer-section
      grid-column: 1
      grid-row: 2
      padding: 1vh 2vh
      overflow: hidden
      border-top: 1px solid rgba(0, 0, 0, 0.1)

      .history-wrapper
        height: 100%
        display: flex
        align-items: center
        
        /deep/ .history
          display: flex
          flex-direction: row
          gap: 2vw
          width: 100%
          overflow-x: auto
          padding-bottom: 5px
          
          &::-webkit-scrollbar
            height: 4px
          &::-webkit-scrollbar-thumb
            background: rgba(0,0,0,0.2)
            border-radius: 2px

          .message
            min-width: 20vw
            border-left: 5px solid currentColor
            padding-left: 1vw
            
            .title
              font-size: 4vh
              font-weight: bold
              margin: 0
            .subtitle
              font-size: 2vh
              opacity: 0.8
              margin: 0

    /* Estilos globais para componentes internos no modo moderno */
    /deep/ .featured-message
      .title
        font-size: 8vw !important
        line-height: 1
      .subtitle, .description
        font-size: 3vw !important

    /deep/ .clock
      .time span
        font-size: 4vw !important
      .date span
        font-size: 1.2vw !important
</style>
