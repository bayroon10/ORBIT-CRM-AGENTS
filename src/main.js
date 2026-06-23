import { createApp } from 'vue'
import './styles/index.css'
import App from './App.vue'
import router from './router'
import animationsPlugin from './plugins/animations.plugin'

const app = createApp(App)
app.use(animationsPlugin)
app.use(router)
app.mount('#app')
