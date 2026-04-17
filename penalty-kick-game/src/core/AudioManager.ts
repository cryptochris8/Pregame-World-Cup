import { Howl } from 'howler'

type SoundName =
  | 'kick'
  | 'goalCheer'
  | 'whistle'
  | 'confetti'
  | 'goalReaction'
  | 'crowdCheer'
  | 'crowdGroan'
  | 'crowdAmbient'
  | 'victoryFanfare'
  | 'defeatStinger'
  | 'postClang'

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
  | 'goalStrike'
  | 'goalNoChance'
  | 'goalTopCorner'
  | 'goalBackOfNet'
  | 'goalClinical'
  | 'saveIncredible'
  | 'saveDenied'
  | 'saveKeeperNo'
  | 'saveWhatAStop'
  | 'saveAcrobatic'
  | 'missJustWide'
  | 'missOverBar'
  | 'missKicking'
  | 'missSoClose'
  | 'stateUnderway'
  | 'stateFinalKick'
  | 'stateSuddenDeath'
  | 'statePerformance'

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
  const base = import.meta.env.BASE_URL

  // SFX — core
  audioManager.loadSound('kick', `${base}audio/sfx/kick.mp3`)
  audioManager.loadSound('goalCheer', `${base}audio/sfx/goalCheer.mp3`)
  audioManager.loadSound('whistle', `${base}audio/sfx/whistle.mp3`)
  audioManager.loadSound('confetti', `${base}audio/sfx/confetti.mp3`)
  audioManager.loadSound('goalReaction', `${base}audio/sfx/crowd/goal-reaction.wav`)

  // SFX — new crowd reactions
  audioManager.loadSound('crowdCheer', `${base}audio/sfx/crowd/crowd_cheer.mp3`)
  audioManager.loadSound('crowdGroan', `${base}audio/sfx/crowd/crowd_groan.mp3`)
  audioManager.loadSound('crowdAmbient', `${base}audio/sfx/crowd/crowd_ambient.mp3`)
  audioManager.loadSound('victoryFanfare', `${base}audio/sfx/victory_fanfare.mp3`)
  audioManager.loadSound('defeatStinger', `${base}audio/sfx/defeat_stinger.mp3`)
  audioManager.loadSound('postClang', `${base}audio/sfx/post_clang.mp3`)

  // Voices — original announcer
  audioManager.loadVoice('whatAGoal', `${base}audio/voice/announcer/what-a-goal.wav`)
  audioManager.loadVoice('beautifulSave', `${base}audio/voice/announcer/beautiful-save.wav`)
  audioManager.loadVoice('nearMiss', `${base}audio/voice/announcer/near-miss.wav`)
  audioManager.loadVoice('crowdGoesWild', `${base}audio/voice/announcer/crowd-goes-wild.wav`)
  audioManager.loadVoice('soClose', `${base}audio/voice/announcer/so-close.wav`)
  audioManager.loadVoice('whatABeauty', `${base}audio/voice/announcer/what-a-beauty.wav`)
  audioManager.loadVoice('greatSave', `${base}audio/voice/great-save.mp3`)
  audioManager.loadVoice('gameStart', `${base}audio/voice/announcer/game-start.wav`)
  audioManager.loadVoice('itsAllOver', `${base}audio/voice/announcer/its-all-over.wav`)

  // Voices — new Sports Guy commentary
  audioManager.loadVoice('goalStrike', `${base}audio/voice/commentary/goal_what_a_strike.mp3`)
  audioManager.loadVoice('goalNoChance', `${base}audio/voice/commentary/goal_keeper_no_chance.mp3`)
  audioManager.loadVoice('goalTopCorner', `${base}audio/voice/commentary/goal_top_corner.mp3`)
  audioManager.loadVoice('goalBackOfNet', `${base}audio/voice/commentary/goal_back_of_net.mp3`)
  audioManager.loadVoice('goalClinical', `${base}audio/voice/commentary/goal_clinical_finish.mp3`)
  audioManager.loadVoice('saveIncredible', `${base}audio/voice/commentary/save_incredible.mp3`)
  audioManager.loadVoice('saveDenied', `${base}audio/voice/commentary/save_denied.mp3`)
  audioManager.loadVoice('saveKeeperNo', `${base}audio/voice/commentary/save_keeper_says_no.mp3`)
  audioManager.loadVoice('saveWhatAStop', `${base}audio/voice/commentary/save_what_a_stop.mp3`)
  audioManager.loadVoice('saveAcrobatic', `${base}audio/voice/commentary/save_acrobatic.mp3`)
  audioManager.loadVoice('missJustWide', `${base}audio/voice/commentary/miss_just_wide.mp3`)
  audioManager.loadVoice('missOverBar', `${base}audio/voice/commentary/miss_over_the_bar.mp3`)
  audioManager.loadVoice('missKicking', `${base}audio/voice/commentary/miss_kicking_himself.mp3`)
  audioManager.loadVoice('missSoClose', `${base}audio/voice/commentary/miss_so_close.mp3`)
  audioManager.loadVoice('stateUnderway', `${base}audio/voice/commentary/state_underway.mp3`)
  audioManager.loadVoice('stateFinalKick', `${base}audio/voice/commentary/state_final_kick.mp3`)
  audioManager.loadVoice('stateSuddenDeath', `${base}audio/voice/commentary/state_sudden_death.mp3`)
  audioManager.loadVoice('statePerformance', `${base}audio/voice/commentary/state_what_a_performance.mp3`)

  // Music
  audioManager.loadMusic('soccer', `${base}audio/music/soccer.wav`)
}
