<template>
  <div class="settings-page">
    <nav class="navbar is-dark">
      <div class="container">
        <div class="navbar-brand">
          <router-link to="/" class="navbar-item">
            <span class="icon"><i class="fa fa-chevron-left"></i></span>
            <span>{{ 'menu.go_back'|trans }}</span>
          </router-link>
          <div class="navbar-item has-text-weight-bold">
            {{ 'settings.title'|trans }}
          </div>
        </div>
      </div>
    </nav>

    <div class="section">
      <div class="container">
        <div class="columns">
          <!-- Sidebar Menu -->
          <div class="column is-3">
            <div class="box menu-box">
              <aside class="menu">
                <p class="menu-label">{{ 'menu.general'|trans }}</p>
                <ul class="menu-list">
                  <li>
                    <a @click="showTab('interface')" :class="{ 'is-active': (tab==='interface') }">
                      <span class="icon"><i class="fa fa-paint-brush"></i></span>
                      {{ 'menu.interface'|trans }}
                    </a>
                  </li>
                  <li>
                    <a @click="showTab('server')" :class="{ 'is-active': (tab==='server') }">
                      <span class="icon"><i class="fa fa-server"></i></span>
                      {{ 'menu.server'|trans }}
                    </a>
                  </li>
                  <li>
                    <a @click="showTab('services')" :class="{ 'is-active': (tab==='services') }" v-if="unities.length">
                      <span class="icon"><i class="fa fa-list"></i></span>
                      {{ 'menu.services'|trans }}
                    </a>
                  </li>
                  <li>
                    <a @click="showTab('sound')" :class="{ 'is-active': (tab==='sound') }">
                      <span class="icon"><i class="fa fa-volume-up"></i></span>
                      {{ 'menu.sound'|trans }}
                    </a>
                  </li>
                </ul>
              </aside>
            </div>
          </div>

          <!-- Main Content -->
          <div class="column is-9">
            <div class="box content-box">
              <form @submit.prevent="save">
                
                <!-- Interface Tab -->
                <div v-if="tab==='interface'">
                  <h2 class="title is-4">{{ 'menu.interface'|trans }}</h2>
                  <div class="columns">
                    <div class="column">
                      <div class="field">
                        <label class="label">{{ 'settings.label.locale'|trans }}</label>
                        <div class="control has-icons-left">
                          <div class="select is-fullwidth">
                            <select v-model="config.locale">
                              <option value="en">English</option>
                              <option value="es">Español</option>
                              <option value="pt_BR">Português (Brasil)</option>
                            </select>
                          </div>
                          <span class="icon is-left"><i class="fa fa-globe"></i></span>
                        </div>
                      </div>
                    </div>
                    <div class="column">
                      <div class="field">
                        <label class="label">{{ 'settings.label.theme'|trans }}</label>
                        <div class="control has-icons-left">
                          <div class="select is-fullwidth">
                            <select v-model="config.theme" @change="changeTheme">
                              <option :value="theme.id" v-for="theme in themes" :key="theme.id">
                                {{ theme.name }}
                              </option>
                            </select>
                          </div>
                          <span class="icon is-left"><i class="fa fa-paint-brush"></i></span>
                        </div>
                      </div>
                    </div>
                  </div>

                  <div v-if="selectedTheme && selectedTheme.options.length">
                    <h3 class="title is-5 mt-5">{{ 'settings.interface.theme_options'| trans }}</h3>
                    <div class="columns is-multiline">
                      <div class="column is-6" v-for="option in selectedTheme.options" :key="option.name">
                        <div class="field">
                          <label class="label">{{ option.label }}</label>
                          <div class="control">
                            <input :type="option.type" :placeholder="option.placeholder" v-model="config.themeOptions[option.name]" class="input">
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>

                  <h3 class="title is-5 mt-5">{{ 'settings.interface.colors'| trans }}</h3>
                  <div class="color-grid">
                    <div class="color-item" v-for="(label, key) in colorLabels" :key="key">
                      <label class="label is-small">{{ label }}</label>
                      <color-picker v-model="config[key]"></color-picker>
                    </div>
                  </div>
                </div>

                <!-- Server Tab -->
                <div v-if="tab==='server'">
                  <h2 class="title is-4">{{ 'menu.server'|trans }}</h2>
                  <div class="field">
                    <label class="label">{{ 'settings.label.server'|trans }}</label>
                    <div class="control"><input class="input" type="url" v-model="config.server" @change="changeServer"></div>
                  </div>
                  <div class="columns">
                    <div class="column"><label class="label">{{ 'settings.label.username'|trans }}</label><input class="input" type="text" v-model="config.username"></div>
                    <div class="column"><label class="label">{{ 'settings.label.password'|trans }}</label><input class="input" type="password" v-model="config.password"></div>
                  </div>
                  <div class="columns">
                    <div class="column"><label class="label">{{ 'settings.label.client_id'|trans }}</label><input class="input" type="text" v-model="config.clientId"></div>
                    <div class="column"><label class="label">{{ 'settings.label.client_secret'|trans }}</label><input class="input" type="password" v-model="config.clientSecret"></div>
                  </div>
                  <div class="field">
                    <label class="label">{{ 'settings.label.unity'|trans }}</label>
                    <div class="control">
                      <div class="select is-fullwidth">
                        <select v-model="config.unity">
                          <option :value="u.id" v-for="u in unities" :key="u.id">{{ u.nome }}</option>
                        </select>
                      </div>
                    </div>
                  </div>
                </div>

                <!-- Sound Tab -->
                <div v-if="tab==='sound'">
                  <h2 class="title is-4">{{ 'menu.sound'|trans }}</h2>
                  <div class="columns">
                    <div class="column is-8">
                      <div class="field">
                        <label class="label">{{ 'settings.label.alert'|trans }}</label>
                        <div class="field has-addons">
                          <div class="control is-expanded">
                            <div class="select is-fullwidth">
                              <select v-model="config.alert">
                                <option v-for="(i, alert) in alerts" :value="i" :key="i">{{ alert }}</option>
                              </select>
                            </div>
                          </div>
                          <div class="control">
                            <button class="button is-info" @click.prevent="testAlert"><i class="fa fa-play"></i></button>
                          </div>
                        </div>
                      </div>
                    </div>
                    <div class="column is-4">
                      <div class="field">
                        <label class="label">{{ 'settings.label.speech_enabled'|trans }}</label>
                        <div class="control">
                          <label class="checkbox card-checkbox">
                            <input type="checkbox" v-model="config.speech"> Vocalizar
                            <button class="button is-small is-info ml-2" @click.prevent="testSpeech"><i class="fa fa-play"></i></button>
                          </label>
                        </div>
                      </div>
                    </div>
                  </div>

                  <div class="box is-light mt-4">
                    <h3 class="title is-6">{{ 'settings.speech.advanced'|trans }}</h3>
                    <div class="columns is-multiline">
                      <div class="column is-6">
                        <label class="label is-small">{{ 'settings.label.voice_gender'|trans }}</label>
                        <div class="select is-fullwidth is-small">
                          <select v-model="config.voiceGender">
                            <option value="female">{{ 'settings.voice.female'|trans }}</option>
                            <option value="male">{{ 'settings.voice.male'|trans }}</option>
                          </select>
                        </div>
                      </div>
                      <div class="column is-6">
                        <label class="label is-small">{{ 'settings.label.speech_volume'|trans }} ({{ (config.speechVolume * 100).toFixed(0) }}%)</label>
                        <input class="slider is-fullwidth" type="range" min="0" max="1" step="0.1" v-model.number="config.speechVolume">
                      </div>
                      <div class="column is-6">
                        <label class="label is-small">{{ 'settings.label.speech_rate'|trans }} ({{ config.speechRate }}x)</label>
                        <input class="slider is-fullwidth" type="range" min="0.5" max="2" step="0.1" v-model.number="config.speechRate">
                      </div>
                      <div class="column is-6">
                        <label class="label is-small">{{ 'settings.label.speech_pitch'|trans }} ({{ config.speechPitch }}x)</label>
                        <input class="slider is-fullwidth" type="range" min="0.5" max="2" step="0.1" v-model.number="config.speechPitch">
                      </div>
                    </div>
                  </div>
                </div>

                <!-- Services Tab -->
                <div v-if="tab==='services'">
                  <h2 class="title is-4">{{ 'menu.services'|trans }}</h2>
                  <div class="columns is-multiline">
                    <div class="column is-6" v-for="service in services" :key="service.servico.id">
                      <label class="checkbox service-card">
                        <input type="checkbox" :value="service.servico.id" v-model="config.services">
                        <span class="ml-2">{{service.sigla}} - {{service.servico.nome}}</span>
                      </label>
                    </div>
                  </div>
                </div>

                <hr>
                <div class="field is-grouped is-grouped-right">
                  <div class="control">
                    <button type="submit" class="button is-success is-large">
                      <span>{{ 'settings.btn.save'|trans }}</span>
                      <span class="icon"><i class="fa fa-save"></i></span>
                    </button>
                  </div>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import audio from '@/services/audio'
  import speech from '@/services/speech'
  import { log } from '@/util/functions'
  import ColorPicker from '@/components/ColorPicker.vue'

  function load (ctx, isInit) {
    ctx.config = JSON.parse(JSON.stringify(ctx.$store.state.config))
    // defaults
    ctx.config.locale = ctx.config.locale || 'pt_BR'
    ctx.config.retries = ctx.config.retries || 5
    ctx.config.theme = ctx.config.theme || ctx.themes[0].id
    ctx.config.themeOptions = ctx.config.themeOptions || {}
    ctx.config.services = ctx.config.services || []
    ctx.config.alert = ctx.config.alert || audio.alertsAvailable.Default
    ctx.config.speech = !!ctx.config.speech
    ctx.config.voiceGender = ctx.config.voiceGender || 'female'
    ctx.config.speechRate = ctx.config.speechRate || 1
    ctx.config.speechPitch = ctx.config.speechPitch || 1
    ctx.config.speechVolume = ctx.config.speechVolume || 1

    const colorFields = [
      'pageBgColorNormal', 'pageFontColorNormal', 'pageBgColorPriority', 'pageFontColorPriority',
      'featuredFontColorNormal', 'featuredFontColorPriority', 'historyFontColorNormal', 'historyFontColorPriority',
      'sidebarBgColorNormal', 'sidebarFontColorNormal', 'sidebarBgColorPriority', 'sidebarFontColorPriority',
      'footerBgColorNormal', 'footerFontColorNormal', 'footerBgColorPriority', 'footerFontColorPriority',
      'clockBgColorNormal', 'clockFontColorNormal', 'clockBgColorPriority', 'clockFontColorPriority'
    ]
    colorFields.forEach(field => {
      if (!ctx.config[field]) {
        ctx.config[field] = field.includes('Bg') ? '#FFFFFF' : '#000000'
      }
    })

    if (isInit) {
      ctx.changeServer()
    }
    ctx.initialServer = ctx.config.server
    ctx.initialUsername = ctx.config.username
    ctx.initialPassword = ctx.config.password
  }

  export default {
    components: { ColorPicker },
    name: 'Settings',
    data () {
      return {
        tab: 'interface',
        config: {},
        alerts: audio.alertsAvailable,
        initialServer: '',
        initialUsername: '',
        initialPassword: '',
        colorLabels: {
          pageBgColorNormal: 'Fundo Página (Normal)',
          pageFontColorNormal: 'Fonte Página (Normal)',
          pageBgColorPriority: 'Fundo Página (Prioridade)',
          pageFontColorPriority: 'Fonte Página (Prioridade)',
          featuredFontColorNormal: 'Fonte Senha (Normal)',
          featuredFontColorPriority: 'Fonte Senha (Prioridade)',
          sidebarBgColorNormal: 'Fundo Lateral (Normal)',
          sidebarFontColorNormal: 'Fonte Lateral (Normal)',
          footerBgColorNormal: 'Fundo Rodapé (Normal)',
          footerFontColorNormal: 'Fonte Rodapé (Normal)',
          clockBgColorNormal: 'Fundo Relógio (Normal)',
          clockFontColorNormal: 'Fonte Relógio (Normal)'
        }
      }
    },
    computed: {
      themes () { return this.$store.state.settings.availableThemes },
      unities () { return this.$store.state.settings.unities },
      services () { return this.$store.state.settings.services },
      selectedTheme () { return this.$store.getters.getTheme(this.config.theme) }
    },
    methods: {
      showTab (tab) { this.tab = tab },
      changeTheme () { this.config.themeOptions = {} },
      changeServer () {
        if (this.config.server) {
          this.$store.dispatch('fetchApiInfo').catch(e => log('Error fetching API info', e))
        }
      },
      save () {
        const isAuthChanged = this.config.server !== this.initialServer || 
                            this.config.username !== this.initialUsername || 
                            this.config.password !== this.initialPassword
        
        this.$store.dispatch('saveConfig', this.config).then(() => {
          if (isAuthChanged) {
            this.$store.dispatch('token').then(() => {
              this.$store.dispatch('fetchUnities').then(() => load(this, false))
            })
          } else if (this.config.unity) {
            this.$store.dispatch('fetchServices', this.config.unity)
          }
          this.$swal('Sucesso', 'Configurações salvas!', 'success')
        })
      },
      testAlert () { if (this.config.alert) audio.playAlert(this.config.alert) },
      testSpeech () {
        speech.speechAll(['Senha', 'A', '1', '0', '1', 'Consultório', '1'], this.config.locale || 'pt-BR', {
          voiceGender: this.config.voiceGender || 'female',
          rate: this.config.speechRate || 1,
          pitch: this.config.speechPitch || 1,
          volume: this.config.speechVolume || 1
        })
      }
    },
    beforeMount () { load(this, true) }
  }
</script>

<style lang="sass" scoped>
.settings-page
  background-color: #f5f5f5
  min-height: 100vh

.navbar
  box-shadow: 0 2px 4px rgba(0,0,0,0.1)

.menu-box
  height: 100%
  padding: 1.5rem

.content-box
  padding: 2rem
  min-height: 70vh

.color-grid
  display: grid
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr))
  gap: 1.5rem
  margin-top: 1rem

.color-item
  background: #fff
  padding: 10px
  border-radius: 8px
  border: 1px solid #eee

.service-card
  display: block
  padding: 10px
  background: #fff
  border-radius: 6px
  border: 1px solid #eee
  transition: all 0.2s
  &:hover
    border-color: #00d1b2
    background: #f9f9f9

.card-checkbox
  display: flex
  align-items: center
  background: #fff
  padding: 10px 15px
  border-radius: 6px
  border: 1px solid #dbdbdb

.slider
  margin-top: 5px
</style>
