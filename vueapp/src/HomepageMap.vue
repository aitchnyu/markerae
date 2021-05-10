<template>
  <div>
    <link
      rel="stylesheet"
      :href="stylesheet"
    >
    <div
      v-if="finishedLoading"
      id="finished-loading-indicator"
      style="display: none"
    />
    <div>
      <l-map
        ref="map"
        :zoom.sync="zoom"
        class="almost-fullscreen fullwidth"
      >
        <l-tile-layer
          url="https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoiamVzdmluIiwiYSI6ImNqeDV5emdpeTA2MHI0OG50c2N4OTZhd28ifQ.aehvE-ZEvTy-Yd0yMTSnWw"
          attribution="&copy; <a href=&quot;http://osm.org/copyright&quot;>OpenStreetMap</a> contributors"
          :options="{tileSize: 512, zoomOffset: -1}"
        />
        <l-marker
          v-for="marker of markers"
          :key="marker.id"
          :icon="icon"
          :lat-lng="marker.location"
        >
          <l-popup>
            {{ marker.name }}
          </l-popup>
        </l-marker>
      </l-map>
    </div>
  </div>
</template>

<script>
  import L from 'leaflet'
  import { LMap, LTileLayer, LIcon, LMarker, LPopup } from 'vue2-leaflet'

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
      LMap,LTileLayer, LPopup, LMarker
    },
    props: {stylesheet: {type:String, required: true}},
    data: function () {
      return {
        ci: CircleIcon,
        icon: icon,
        finishedLoading: false,
        zoom: 2,
        markers: CONSTANTS.markers,
        extentPoints: CONSTANTS.extent_points
      }
    },
    mounted () {
      window.homepageMap = this
      console.log('mounted homepagemap')
      const map = this.getLeaflet()
      let crosshair = new L.marker(map.getCenter(), {icon: crosshairIcon, clickable: false})
      crosshair.addTo(map)
      map.on('move', (e) => {
        crosshair.setLatLng(map.getCenter())
      })
      map.once('moveend zoomend', () => this.finishedLoading = true)
      map.fitBounds(L.polyline(this.extentPoints).getBounds())
    },
    methods: {
      getLeaflet () {
        return this.$refs.map.mapObject
      },
      diagnostics () {
        const center = this.getLeaflet().getCenter()
        return JSON.stringify({center: [center.lat, center.lng]})
      },
      createMarker() {
        console.log("create marker", this)
        const mapCenter = this.$refs.map.mapObject.getCenter()
        window.location = `/markers/create/${mapCenter.lat}/${mapCenter.lng}`
      },
    }
  };
</script>

<style>
  @import "../node_modules/leaflet/dist/leaflet.css";
  .fullwidth {
    width: 100%;
  }
  /*From https://stackoverflow.com/a/41869915*/
  @media(max-width: 1079px) {
    .almost-fullscreen {
      height: 95vh;
    }
  }
  @media not all and (max-width: 1079px) {
    .almost-fullscreen {
      height: 99vh;
    }
  }
</style>
