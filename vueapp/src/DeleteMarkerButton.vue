<template>
  <span>
    <link
      rel="stylesheet"
      :href="stylesheet"
    >
    <b-dropdown>
      <button
        slot="trigger"
        class="button is-small is-inverted is-danger"
      >
        Delete &darr;
      </button>
      <b-dropdown-item
        class="delete-marker"
        @click="deleteMarker(markerId)"
      >This</b-dropdown-item>
      <b-dropdown-item
        class="delete-markers"
        @click="deleteMarkers(markerId)"
      >This and older</b-dropdown-item>
    </b-dropdown>
  </span>
</template>

<script>
import { BDropdown, BDropdownItem } from 'buefy/dist/components/dropdown/index'

export default {
  name: 'DeleteMarkerButton',
  components: {BDropdown, BDropdownItem},
  props: {
    stylesheet: {type:String, required: true},
    markerId: {type:String, required: true}
  },
  methods: {
    deleteMarker(id) {
      window.location = `markers/delete/${id}`
    },
    deleteMarkers(id) {
      window.location = `markers/delete-markers/${id}`
    }
  }
};
</script>
