<template>
  <div class="weather-widget">
    <div v-if="weather" class="weather-info">
      <div class="temperature">
        <span class="value">{{ weather.temperature }}°</span>
        <span class="unit">C</span>
      </div>
      <div class="condition">
        <i :class="getWeatherIcon(weather.condition)" class="fa"></i>
        <span class="text">{{ weather.condition }}</span>
      </div>
    </div>
    <div v-else class="weather-loading">
      <i class="fa fa-cloud"></i>
      <span>{{ 'climate.loading'|trans }}</span>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Weather',
  props: {
    latitude: {
      type: Number,
      default: null
    },
    longitude: {
      type: Number,
      default: null
    },
    fontColor: {
      type: String,
      default: '#000000'
    }
  },
  data () {
    return {
      weather: null,
      refreshInterval: null
    }
  },
  methods: {
    fetchWeather () {
      if (!this.latitude || !this.longitude) {
        this.getGeolocation()
        return
      }

      // Using Open-Meteo API (free, no API key required)
      const url = `https://api.open-meteo.com/v1/forecast?latitude=${this.latitude}&longitude=${this.longitude}&current=temperature_2m,weather_code&timezone=auto`
      
      fetch(url)
        .then(response => response.json())
        .then(data => {
          if (data.current) {
            this.weather = {
              temperature: Math.round(data.current.temperature_2m),
              condition: this.getWeatherDescription(data.current.weather_code)
            }
          }
        })
        .catch(error => {
          console.error('Weather fetch error:', error)
        })
    },
    getGeolocation () {
      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(
          position => {
            this.$emit('location-found', {
              latitude: position.coords.latitude,
              longitude: position.coords.longitude
            })
            this.fetchWeather()
          },
          error => {
            console.error('Geolocation error:', error)
          }
        )
      }
    },
    getWeatherDescription (code) {
      const descriptions = {
        0: 'Céu Limpo',
        1: 'Parcialmente Nublado',
        2: 'Nublado',
        3: 'Encoberto',
        45: 'Nevoeiro',
        48: 'Nevoeiro com Geada',
        51: 'Garoa Leve',
        53: 'Garoa Moderada',
        55: 'Garoa Densa',
        61: 'Chuva Leve',
        63: 'Chuva Moderada',
        65: 'Chuva Densa',
        71: 'Neve Leve',
        73: 'Neve Moderada',
        75: 'Neve Densa',
        77: 'Grãos de Neve',
        80: 'Chuva Leve Intermitente',
        81: 'Chuva Moderada Intermitente',
        82: 'Chuva Densa Intermitente',
        85: 'Neve Leve Intermitente',
        86: 'Neve Densa Intermitente',
        95: 'Trovoada',
        96: 'Trovoada com Granizo Leve',
        99: 'Trovoada com Granizo Densa'
      }
      return descriptions[code] || 'Desconhecido'
    },
    getWeatherIcon (condition) {
      if (condition.includes('Céu Limpo')) return 'fa-sun'
      if (condition.includes('Nublado')) return 'fa-cloud'
      if (condition.includes('Chuva')) return 'fa-cloud-rain'
      if (condition.includes('Neve')) return 'fa-snowflake'
      if (condition.includes('Trovoada')) return 'fa-bolt'
      if (condition.includes('Nevoeiro')) return 'fa-smog'
      return 'fa-cloud'
    }
  },
  mounted () {
    this.fetchWeather()
    this.refreshInterval = setInterval(() => {
      this.fetchWeather()
    }, 600000) // Refresh every 10 minutes
  },
  beforeDestroy () {
    if (this.refreshInterval) {
      clearInterval(this.refreshInterval)
    }
  }
}
</script>

<style lang="sass" scoped>
  .weather-widget
    display: flex
    align-items: center
    justify-content: center
    gap: 1.5vh

    .weather-info
      display: flex
      align-items: center
      gap: 1.5vh

      .temperature
        display: flex
        align-items: baseline
        gap: 0.5vh

        .value
          font-size: 4vh
          font-weight: bold

        .unit
          font-size: 2vh

      .condition
        display: flex
        flex-direction: column
        align-items: center
        gap: 0.5vh

        i
          font-size: 3vh

        .text
          font-size: 1.5vh
          text-align: center

    .weather-loading
      display: flex
      align-items: center
      gap: 1vh

      i
        font-size: 3vh

      span
        font-size: 1.5vh
</style>
