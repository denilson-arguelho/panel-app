<template>
  <div class="novosga-modern layout-content" :style="{ 'background-color': color('pageBgColor'), 'color': color('pageFontColor') }">
    <!-- Fullscreen Button (Hidden until hover) -->
    <div class="fullscreen-control" @click="toggleFullscreen" :title="isFullscreen ? 'Sair de Tela Cheia' : 'Tela Cheia'">
      <i class="fa" :class="isFullscreen ? 'fa-compress' : 'fa-expand'"></i>
    </div>

    <!-- Main Grid Layout -->
    <div class="main-grid">
      <!-- Header Section (Relógio) -->
      <header class="header-section" :style="{ 'background-color': color('clockBgColor'), 'color': color('clockFontColor') }">
        <clock :locale="config.locale" :dateFormat="'date_format'|trans" :fontColor="color('clockFontColor')"></clock>
      </header>

      <!-- Main Content Area (Vídeo/YouTube ou Senha) -->
      <main class="main-content">
        <div v-if="showVideo && config.themeOptions.videoUrl" class="video-container">
          <iframe
            v-if="isYoutubeUrl(config.themeOptions.videoUrl)"
            :src="getEmbedUrl(config.themeOptions.videoUrl)"
            class="video-player"
            frameborder="0"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
            allowfullscreen>
          </iframe>
          <video v-else :src="config.themeOptions.videoUrl" class="video-player" autoplay loop muted></video>
        </div>
        <featured v-else :message="lastMessage" v-if="lastMessage" :fontColor="color('featuredFontColor', 'pageFontColor')"></featured>
      </main>

      <!-- Sidebar Right (Histórico) -->
      <aside class="sidebar-right" :style="{ 'background-color': color('sidebarBgColor'), 'color': color('sidebarFontColor') }">
        <div class="sidebar-header">
          <h2 class="title" :style="{ 'color': color('sidebarFontColor') }">
            {{ 'history.title'|trans }}
          </h2>
          <history
            v-if="lastMessage"
            :messages="messages"
            :fontColorNormal="config.historyFontColorNormal || config.sidebarFontColorNormal"
            :fontColorPriority="config.historyFontColorPriority || config.sidebarFontColorPriority">
          </history>
        </div>
      </aside>

      <!-- Footer Section -->
      <footer class="footer-section" :style="{ 'background-color': color('footerBgColor'), 'color': color('footerFontColor') }">
        <div class="footer-left">
          <img :src="logoUrl" class="logo">
          <h3 v-if="config.themeOptions.footerText" :style="{ 'color': color('footerFontColor') }">
            {{ config.themeOptions.footerText }}
          </h3>
        </div>
        <div class="footer-right">
          <weather :fontColor="color('footerFontColor')"></weather>
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
        lastMessage: {},
        messageQueue: [],
        isFullscreen: false,
        showVideo: false
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
        this.showVideo = false
        
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
        
        return `https://www.youtube.com/embed/${videoId}?autoplay=1&mute=1`
      },
      color (prefix, fallback) {
        const peso = this.lastMessage.$data ? this.lastMessage.$data.peso : 0
        const suffix = peso > 0 ? 'Priority' : 'Normal'
        return this.config[prefix + suffix] || this.config[fallback + suffix]
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
    }
  }
</script>

<style lang="sass" scoped>
  .novosga-modern
    .layout-content
      position: fixed
      width: 100%
      height: 100%
      overflow: hidden

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
      width: 5vh
      height: 5vh
      border-radius: 50%
      display: flex
      align-items: center
      justify-content: center
      font-size: 2.5vh
      
      &:hover
        opacity: 1
        background-color: rgba(0, 0, 0, 0.8)

    &:hover .fullscreen-control
      opacity: 1

    .main-grid
      display: grid
      grid-template-columns: 1fr 25vw
      grid-template-rows: 15vh 1fr 15vh
      height: 100vh
      gap: 0

      @media (max-width: 1024px)
        grid-template-columns: 1fr 30vw
        grid-template-rows: 12vh 1fr 12vh

      @media (max-width: 768px)
        grid-template-columns: 1fr
        grid-template-rows: 10vh 1fr 10vh
        
        .sidebar-right
          display: none

    .header-section
      grid-column: 1 / -1
      display: flex
      align-items: center
      justify-content: center
      padding: 2vh
      border-bottom: 2px solid rgba(0, 0, 0, 0.1)

      .clock
        .time
          span
            font-size: 4vw
          span.hours
            font-weight: bold
          span.seconds
            font-style: italic
        .date
          text-align: center
          span
            font-size: 2vw
            font-weight: bold

    .main-content
      grid-column: 1
      grid-row: 2
      display: flex
      align-items: center
      justify-content: center
      padding: 2vh
      overflow: hidden

      .video-container
        width: 100%
        height: 100%
        display: flex
        align-items: center
        justify-content: center

        .video-player
          width: 100%
          height: 100%
          object-fit: contain
          border-radius: 8px

      .featured-message
        text-align: center
        .title
          font-size: 25vw
          font-weight: bold
          line-height: 1
        .subtitle
          font-size: 8vw
          margin-top: 1vh
        .description
          font-size: 8vw
          margin-top: 1vh

    .sidebar-right
      grid-column: 2
      grid-row: 2
      display: flex
      flex-direction: column
      border-left: 2px solid rgba(0, 0, 0, 0.1)
      overflow-y: auto

      .sidebar-header
        flex: 1
        padding: 1.5vh
        overflow-y: auto

        .title
          text-align: center
          font-weight: bold
          margin-bottom: 1.5vh
          font-size: 2.5vh

        .history
          .message
            background-color: transparent
            border-left: 4px solid rgba(0, 0, 0, 0.3)
            padding-left: 1rem
            margin-bottom: 1rem

            span
              text-align: left
              display: block
            .title
              font-size: 6vh
              font-weight: bold
              text-align: left
              margin-bottom: 0.5vh
            .subtitle
              font-size: 3vh
              font-style: italic
              text-align: left

    .footer-section
      grid-column: 1 / -1
      display: grid
      grid-template-columns: 1fr 1fr
      align-items: center
      padding: 1.5vh 2vh
      border-top: 2px solid rgba(0, 0, 0, 0.1)

      @media (max-width: 768px)
        grid-template-columns: 1fr

      .footer-left
        display: flex
        align-items: center
        gap: 1.5vh

        .logo
          height: 8vh
          max-width: 15vw
          object-fit: contain

        h3
          font-size: 2.5vh
          font-weight: bold
          margin: 0

      .footer-right
        text-align: right
        padding-right: 2vh

        h3
          font-size: 2.5vh
          font-weight: bold
          margin: 0

        @media (max-width: 768px)
          text-align: left
          padding-right: 0

    /* Scrollbar styling for sidebar */
    .sidebar-right::-webkit-scrollbar
      width: 8px

    .sidebar-right::-webkit-scrollbar-track
      background: transparent

    .sidebar-right::-webkit-scrollbar-thumb
      background: rgba(0, 0, 0, 0.2)
      border-radius: 4px

      &:hover
        background: rgba(0, 0, 0, 0.4)
</style>
