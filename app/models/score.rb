class Score < ApplicationRecord
  belongs_to :game, counter_cache: :scores_count

  # Ties go to whoever reached the score first.
  scope :ranked, -> { order(score: :desc, updated_at: :asc, id: :asc) }

  normalizes :name, with: ->(name) { name.strip }

  validates :name, presence: true, length: { maximum: 50 }
  validates :score, numericality: { only_integer: true, in: -(2**63)..(2**63 - 1) }

  # 1-based position on the game's leaderboard, or nil if the score didn't make it.
  def rank
    return unless persisted?

    position = game.leaderboard.ids.index(id)
    position + 1 if position
  end
end
