module EtkinlikIo
  class CandidateCleanup
    def call
      now = Time.current
      expired_marked = ExternalEventCandidate
                       .where(status: %w[pending skipped hidden])
                       .where("COALESCE(ends_at, starts_at) < ?", now)
                       .update_all(status: "expired", updated_at: now)

      pruned = ExternalEventCandidate
               .where(status: %w[rejected skipped hidden])
               .where("COALESCE(ends_at, starts_at) < ?", 14.days.ago)
               .delete_all

      expired_deleted = ExternalEventCandidate
                        .expired
                        .where("updated_at < ?", 30.days.ago)
                        .delete_all

      stripped = ExternalEventCandidate
                 .approved
                 .where("COALESCE(ends_at, starts_at) < ?", 45.days.ago)
                 .where.not(raw_data: {})
                 .update_all(raw_data: {}, mapped_data: {}, updated_at: now)

      {
        expired_marked: expired_marked,
        pruned: pruned,
        expired_deleted: expired_deleted,
        approved_payloads_stripped: stripped
      }
    end
  end
end
