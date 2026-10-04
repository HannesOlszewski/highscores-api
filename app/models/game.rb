class Game < ApplicationRecord
  LEADERBOARD_SIZE = 50

  has_many :scores, dependent: :delete_all

  # Game builds send this as a bearer token to submit scores.
  has_secure_token :api_key

  normalizes :name, with: ->(name) { name.strip }

  # The name is the game's identifier in API URLs (/games/<name>/scores), so keep it URL-safe.
  validates :name, presence: true, uniqueness: true, length: { maximum: 64 },
    exclusion: { in: %w[ new ], message: "is reserved" },
    format: { with: /\A[A-Za-z0-9_-]+\z/, message: "can only contain letters, numbers, dashes and underscores" }

  # Use the persisted name so URLs stay valid while an invalid rename is being re-rendered.
  def to_param = name_in_database

  def leaderboard
    scores.ranked.limit(LEADERBOARD_SIZE)
  end

  # Records a player's score, keeping only their best one, and trims the leaderboard to
  # LEADERBOARD_SIZE entries. Returns the player's Score; check #rank to see whether it
  # made the leaderboard.
  def submit_score(name:, score:)
    transaction do
      entry = scores.find_or_initialize_by(name: name)
      best = entry.score
      entry.score = score

      if entry.valid?
        entry.score = best if best && entry.score < best
        entry.save!
        scores.ranked.offset(LEADERBOARD_SIZE).destroy_all
      end

      entry
    end
  rescue ActiveRecord::RecordNotUnique
    # Another request created the same player's entry concurrently; retry as an update.
    retry
  end
end
