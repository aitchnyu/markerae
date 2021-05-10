<template>
  <div>
    <div style="height: 700px; width: 100%">
      <l-map
        ref="map"
        :zoom.sync="zoom"
      >
        <l-tile-layer
          url="https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoiamVzdmluIiwiYSI6ImNqeDV5emdpeTA2MHI0OG50c2N4OTZhd28ifQ.aehvE-ZEvTy-Yd0yMTSnWw"
          attribution="&copy; <a href=&quot;http://osm.org/copyright&quot;>OpenStreetMap</a> contributors"
          :options="{tileSize: 512, zoomOffset: -1}"
        />
        <!--        <l-marker :icon="icon" v-for="issue of issues" :key="issue.id" :lat-lng="issue.location">-->
        <!--          <l-popup>-->
        <!--            {{ issue.title }}-->
        <!--            <br>-->
        <!--            <span v-for="tag of issue.tags" :key="tag.id">&bull; {{tag.name}} &nbsp;&nbsp;</span>-->
        <!--          </l-popup>-->
        <!--        </l-marker>-->
        <!--        <l-polygon v-if="boundary" :lat-lngs="boundary" :fill="false"/>-->
      </l-map>
    </div>
  </div>
</template>

<script>
import L from 'leaflet'
import CircleIcon from '@/assets/circle.png'
// import PlusIcon from './plus.png'
import { LMap, LTileLayer, LIcon, LMarker, LPopup, LTooltip, LPolygon } from 'vue2-leaflet'
import 'leaflet/dist/leaflet.css'

const icon = L.icon({
  iconUrl: CircleIcon,
  iconSize: [8, 8], // size of the icon
  iconAnchor: [4, 4], // point of the icon which will correspond to marker's location
})

export default {
  name: 'HomepageMap',
  components: {
    LMap,LTileLayer
  },
  props: {
    // msg: String,
  },
  data: function () {
    return {
      icon: icon,
      zoom: 10

    }

  }
};
</script>
