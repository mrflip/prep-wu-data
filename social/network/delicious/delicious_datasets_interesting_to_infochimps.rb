
# '%data%' '%stats%' '%statistic%'
DELICIOUS_DATASETS_INTERESTING_TO_INFOCHIMPS = %{
        SELECT COUNT(*) AS `tagging_count`, t.name AS `tag_name`, d.handle AS `asset_url`, d.name AS `asset_name`, d.facts
          FROM          tags t
          LEFT JOIN taggings tg ON tg.tag_id = t.id
          LEFT JOIN datasets d  ON tg.taggable_id = d.id
          WHERE         t.name LIKE '%semantic%'
            OR          t.name LIKE '%statistics%'
            OR          t.name LIKE '%stats%'
            OR          t.name LIKE '%data%'
          GROUP BY      d.id
          ORDER BY      tagging_count DESC, t.name
}

def delicious_datasets_interesting_to_infochimps()
  repository(:default).adapter.query(DELICIOUS_DATASETS_INTERESTING_TO_INFOCHIMPS)
end
