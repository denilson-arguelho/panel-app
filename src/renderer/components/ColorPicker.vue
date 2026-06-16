<template>
  <div class="color-picker-wrapper">
    <div class="color-input-group">
      <input
        type="color"
        :value="value"
        @input="updateColor"
        class="color-input"
        :title="value"
      >
      <input
        type="text"
        :value="value"
        @input="updateColorText"
        class="input is-medium color-text"
        placeholder="#000000"
      >
    </div>
  </div>
</template>

<script>
export default {
  name: 'ColorPicker',
  props: {
    value: {
      type: String,
      default: '#000000'
    }
  },
  methods: {
    updateColor (event) {
      this.$emit('input', event.target.value)
    },
    updateColorText (event) {
      const color = event.target.value
      if (/^#[0-9A-F]{6}$/i.test(color)) {
        this.$emit('input', color)
      }
    }
  }
}
</script>

<style lang="sass" scoped>
  .color-picker-wrapper
    display: flex
    align-items: center
    gap: 1rem

    .color-input-group
      display: flex
      align-items: center
      gap: 0.5rem
      flex: 1

      .color-input
        width: 60px
        height: 40px
        border: 2px solid #dbdbdb
        border-radius: 4px
        cursor: pointer
        padding: 4px

      .color-text
        flex: 1
        font-family: monospace
        font-size: 0.9rem
</style>
