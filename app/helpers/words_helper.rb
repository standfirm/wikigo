module WordsHelper
  def markdown(str)
    processor = Qiita::Markdown::Processor.new( hostname: request.host_with_port )
    processor.call(str)[:output].to_s
  end

  def add_word_link(word)
    body = word.body
    except_word = word.title

    dic = []

    #長いキーワードから別の文字列に置き換えて、それより短い文字列で置き換えられることを防ぐ
    #TRIEなどのアルゴリズムで高速化するのが望ましい
    word_list(except_word).each do |w|
      hashed_w = Digest::SHA1.hexdigest(w)
      dic << [hashed_w, w]
      body = body.gsub(w, hashed_w) 
    end

    dic.each do |t|
      body = body.gsub(t.first, link_to(t.last, url_for(controller: :words, action: :show, id: t.last)))
    end
    body
  end

  def has_version?(w)
    w.versions.count > 0
  end

  def recent_words
    Word.recent_words(Option.list_size_of_recent_words_parts)
  end

  # For views/words/_form.html
  def template_list
    Word.tagged_with('Template').map do |w|
      [w.title, w.body]
    end
  end

  private 
  def word_list(except_word)
    Word.where.not(title: except_word).order("LENGTH(title) DESC").pluck(:title)
  end
end
