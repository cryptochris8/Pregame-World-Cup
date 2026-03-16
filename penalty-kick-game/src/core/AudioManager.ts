import { Howl } from 'howler'

type SoundName =
  | 'kick'
  | 'goalCheer'
  | 'whistle'
  | 'confetti'
  | 'goalReaction'

type VoiceName =
  | 'whatAGoal'
  | 'beautifulSave'
  | 'nearMiss'
  | 'crowdGoesWild'
  | 'whatABeauty'
  | 'greatSave'
  | 'soClose'
  | 'gameStart'
  | 'itsAllOver'

type MusicName = 'soccer'

class AudioManager {
  private sounds: Map<string, Howl> = new Map()
  private music: Map<string, Howl> = new Map()
  private voices: Map<string, Howl> = new Map()
  private currentMusic: string | null = null
  private currentVoice: Howl | null = null
  private _sfxVolume = 0.7
  private _musicVolume = 0.4
  private _voiceVolume = 0.85

  setSfxVolume(vol: number) {
    this._sfxVolume = vol
    this.sounds.forEach((s) => s.volume(vol))
  }

  setMusicVolume(vol: number) {
    this._musicVolume = vol
    this.music.forEach((m) => m.volume(vol))
  }

  setVoiceVolume(vol: number) {
    this._voiceVolume = vol
    this.voices.forEach((v) => v.volume(vol))
  }

  loadSound(name: SoundName, src: string) {
    const sound = new Howl({ src: [src], volume: this._sfxVolume })
    this.sounds.set(name, sound)
  }

  loadMusic(name: MusicName, src: string) {
    const m = new Howl({ src: [src], volume: this._musicVolume, loop: true })
    this.music.set(name, m)
  }

  loadVoice(name: VoiceName, src: string) {
    const v = new Howl({ src: [src], volume: this._voiceVolume })
    this.voices.set(name, v)
  }

  play(name: SoundName) {
    this.sounds.get(name)?.play()
  }

  stop(name: SoundName) {
    this.sounds.get(name)?.stop()
  }

  playVoice(name: VoiceName) {
    if (this.currentVoice && this.currentVoice.playing()) {
      this.currentVoice.stop()
    }
    const v = this.voices.get(name)
    if (v) {
      v.play()
      this.currentVoice = v
    }
  }

  playMusic(name: MusicName) {
    if (this.currentMusic === name) return
    if (this.currentMusic) {
      const prev = this.currentMusic
      this.music.get(prev)?.fade(this._musicVolume, 0, 500)
      setTimeout(() => {
        this.music.get(prev)?.stop()
      }, 500)
    }
    const m = this.music.get(name)
    if (m) {
      m.volume(0)
      m.play()
      m.fade(0, this._musicVolume, 500)
      this.currentMusic = name
    }
  }

  stopMusic() {
    if (this.currentMusic) {
      const prev = this.currentMusic
      this.music.get(prev)?.fade(this._musicVolume, 0, 500)
      setTimeout(() => {
        this.music.get(prev)?.stop()
      }, 500)
      this.currentMusic = null
    }
  }

  stopAll() {
    this.sounds.forEach((s) => s.stop())
    this.voices.forEach((v) => v.stop())
    this.currentVoice = null
    this.stopMusic()
  }
}

export type { SoundName, VoiceName, MusicName }
export const audioManager = new AudioManager()

/** Load all soccer audio at startup */
export function loadSoccerAudio() {
  // SFX
  audioManager.loadSound('kick', '/audio/sfx/kick.mp3')
  audioManager.loadSound('goalCheer', '/audio/sfx/goalCheer.mp3')
  audioManager.loadSound('whistle', '/audio/sfx/whistle.mp3')
  audioManager.loadSound('confetti', '/audio/sfx/confetti.mp3')
  audioManager.loadSound('goalReaction', '/audio/sfx/crowd/goal-reaction.wav')

  // Voices
  audioManager.loadVoice('whatAGoal', '/audio/voice/announcer/what-a-goal.wav')
  audioManager.loadVoice('beautifulSave', '/audio/voice/announcer/beautiful-save.wav')
  audioManager.loadVoice('nearMiss', '/audio/voice/announcer/near-miss.wav')
  audioManager.loadVoice('crowdGoesWild', '/audio/voice/announcer/crowd-goes-wild.wav')
  audioManager.loadVoice('soClose', '/audio/voice/announcer/so-close.wav')
  audioManager.loadVoice('whatABeauty', '/audio/voice/announcer/what-a-beauty.wav')
  audioManager.loadVoice('greatSave', '/audio/voice/great-save.mp3')
  audioManager.loadVoice('gameStart', '/audio/voice/announcer/game-start.wav')
  audioManager.loadVoice('itsAllOver', '/audio/voice/announcer/its-all-over.wav')

  // Music
  audioManager.loadMusic('soccer', '/audio/music/soccer.wav')
}
