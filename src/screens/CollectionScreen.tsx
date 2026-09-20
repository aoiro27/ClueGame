import { useState } from 'react'
import { OwlMascot } from '../components/OwlMascot'
import { TreasureArt } from '../components/TreasureArt'
import { rarityLabel } from '../lib/messages'
import { speakJapanese } from '../lib/speech'
import { getTreasure, TREASURES, uniqueCollected } from '../lib/treasures'
import { useGameStore } from '../store/gameStore'

export function CollectionScreen() {
  const collection = useGameStore((state) => state.collection)
  const goTo = useGameStore((state) => state.goTo)
  const owned = uniqueCollected(collection)
  const [selectedId, setSelectedId] = useState<string | null>(owned[0]?.id ?? null)
  const selected = selectedId ? getTreasure(selectedId) : null

  return (
    <section className="screen collection">
      <header className="topbar">
        <button type="button" className="btn text" onClick={() => goTo('home')}>
          ホーム
        </button>
        <h1 data-testid="collection-title">たからばこ</h1>
      </header>
      {owned.length === 0 ? (
        <div className="empty">
          <OwlMascot mood="sleep" />
          <p>まだたからはないよ。</p>
          <p className="quiet">ぼうけんをクリアすると、ここにふえるよ。</p>
        </div>
      ) : (
        <>
          {selected ? (
            <article className="detail-card">
              <TreasureArt treasure={selected} className="detail-art" />
              <p className="rarity">{rarityLabel(selected.rarity)}</p>
              <h2>{selected.name}</h2>
              <p>{selected.flavor}</p>
              <button
                type="button"
                className="btn secondary"
                onClick={() => speakJapanese(`${selected.name}。${selected.flavor}`)}
              >
                なまえをきく
              </button>
            </article>
          ) : null}
          <ul className="shelf">
            {TREASURES.map((treasure) => {
              const got = owned.some((item) => item.id === treasure.id)
              return (
                <li key={treasure.id}>
                  <button
                    type="button"
                    className={`shelf-item ${got ? 'got' : 'locked'} ${selectedId === treasure.id ? 'selected' : ''}`}
                    disabled={!got}
                    onClick={() => {
                      setSelectedId(treasure.id)
                      speakJapanese(treasure.name)
                    }}
                  >
                    {got ? (
                      <TreasureArt treasure={treasure} />
                    ) : (
                      <span className="silhouette">？</span>
                    )}
                    <span>{got ? treasure.name : '？？？'}</span>
                  </button>
                </li>
              )
            })}
          </ul>
          <p className="quiet">
            {owned.length} / {TREASURES.length} あつめているよ
          </p>
        </>
      )}
    </section>
  )
}
