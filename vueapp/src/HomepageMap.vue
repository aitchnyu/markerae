<template>
  <div>
    <div>
      <l-map :zoom.sync="zoom" ref="map" class="almost-fullscreen fullwidth">
        <l-tile-layer url='https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoiamVzdmluIiwiYSI6ImNqeDV5emdpeTA2MHI0OG50c2N4OTZhd28ifQ.aehvE-ZEvTy-Yd0yMTSnWw'
                      attribution='&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
                      :options="{tileSize: 512, zoomOffset: -1}"/>
                <l-marker :icon="icon" v-for="marker of markers" :key="marker.id" :lat-lng="marker.location">
                  <l-popup>
                    {{ marker.name }}
                  </l-popup>
                </l-marker>
      </l-map>
    </div>
    <portal selector="#markers">
      <div v-for="marker of markers" :key="marker.id">
        {{ marker.name }}
        <b-dropdown>
          <button class="button is-small is-inverted is-danger" slot="trigger">
            Delete &darr;
          </button>
          <b-dropdown-item @click="deleteMarker(marker.id)">This</b-dropdown-item>
          <b-dropdown-item @click="deleteMarkers(marker.id)">This and older</b-dropdown-item>
        </b-dropdown>
      </div>
    </portal>
  </div>
</template>

<script>
  import { BDropdown, BDropdownItem } from 'buefy/dist/components/dropdown/index'
  import L from 'leaflet'
  import { LMap, LTileLayer, LIcon, LMarker, LPopup, LTooltip, LPolygon } from 'vue2-leaflet'
  import { Portal } from '@linusborg/vue-simple-portal'

  import CircleIcon from '@/assets/circle.png'
  import PlusIcon from '@/assets/plus.png'

  const icon = L.icon({
    iconUrl: CircleIcon,
    iconSize: [8, 8], // size of the icon
    iconAnchor: [4, 4], // point of the icon which will correspond to marker's location
  })

  const crosshairIcon = L.icon({
    iconUrl: PlusIcon,
    iconSize: [20, 20], // size of the icon
    iconAnchor: [10, 10], // point of the icon which will correspond to marker's location
  })

  export default {
    name: 'HomepageMap',
    components: {
      BDropdown, BDropdownItem, LMap,LTileLayer, LPopup, LMarker, Portal
    },
    mounted () {
      window.createMarker = this.createMarker
      console.log('mounted')
      const map = this.$refs.map.mapObject
      let crosshair = new L.marker(map.getCenter(), {icon: crosshairIcon, clickable: false})
      crosshair.addTo(map)
      map.on('move', (e) => {
        crosshair.setLatLng(map.getCenter())
      })
      map.fitBounds(L.polyline(this.extentPoints).getBounds())
    },
    methods: {
      createMarker() {
        console.log("create marker", this)
        const mapCenter = this.$refs.map.mapObject.getCenter()
        window.location = `/markers/create/${mapCenter.lat}/${mapCenter.lng}`
      },
      deleteMarker(id) {
        window.location = `markers/delete/${id}`
      },
      deleteMarkers(id) {
        window.location = `markers/delete-markers/${id}`
      }
    },
    data: function () {
      return {
        ci: CircleIcon,
        icon: icon,
        zoom: 2,
        markers: CONSTANTS.markers,
        extentPoints: CONSTANTS.extent_points
      }
    }
  };
</script>

<style>
  @import "../node_modules/leaflet/dist/leaflet.css";
  .fullwidth {
    width: 100%;
  }
  /*From https://stackoverflow.com/a/41869915*/
  @media(max-width: 767px) {
    .almost-fullscreen {
      height: 95vh;
    }
  }
  @media not all and (max-width: 767px) {
    .almost-fullscreen {
      height: 99vh;
    }
  }
</style>
