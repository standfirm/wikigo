class Word < ApplicationRecord
  acts_as_taggable
  acts_as_favable
  acts_as_commentable

  include PublicActivity::Model
  include TagFinder
  has_paper_trail on: [:update, :destroy]

  validates :title, presence: true
  validates :title, uniqueness: true

  def self.find(input)
    if input.is_a?(Integer)
      super
    else
      find_by_title(input)
    end
  end

  def to_param
    title
  end

  def self.recent_words(num)
    Word.all.limit(num).order('updated_at desc')
  end

  def to_middleman
    <<"EOS"
---
title: #{self.title}
date: #{self.created_at}
tags: #{self.tag_list}
wiki:word_id: #{self.id}
---

#{self.body}
EOS
  end
end
