# -*- coding: utf-8 -*-
description 'Document browser aspect'
dependencies 'utils/shell'

Aspect.create(:documentbrowser, priority: 1, cacheable: true, accepts: %r{^application/pdf$|postscript$}) do
  def count_pages
    content = @page.content
    page_count = 0
    if @page.mime == 'application/pdf'
      page_count = $1.to_i if Shell.pdfinfo('-').run(content) =~ /Pages:\s+(\d+)/
    else
      content = Shell.cmd($1 == 'gz' ? 'gunzip' : 'bunzip2').run(content) if @page.mime.to_s =~ /(gz|bz)/
      page_count = $1.to_i if content =~ /^%%Pages:\s+(\d+)$/
    end
    page_count
  end

  def call(context, page)
    @page = page
    @page_nr = [context.params[:page].to_i, 1].max
    @page_count = count_pages
    render :documentbrowser
  end
end

__END__

@@ documentbrowser.slim
= pagination(@page, @page_count, @page_nr, aspect: 'documentbrowser')
p
  img src=build_path(@page, aspect: 'image', geometry: '480x>', trim: 1, page: @page_nr)
= pagination(@page, @page_count, @page_nr, aspect: 'documentbrowser')
h3= :information.t
table
  tbody
    tr
      td= :name.t
      td= @page.name
    tr
      td= :attribute_title.t
      td= @page.title
    tr
      td= :attribute_description.t
      td= @page.attributes['description']
    - if @page.version
      tr
        td= :last_modified.t
        td= date @page.version.date
      tr
        td= :version.t
        td.version= @page.version
    tr
      td= :type.t
      td= @page.mime.comment.blank? ? @page.mime : "#{@page.mime.comment} (#{@page.mime})"
    tr
      td= :download.t
      td
        a href=build_path(@page, aspect: 'download') = :download.t
@@ locale.yml
cs:
  aspect_documentbrowser: 'Document Browser'
  download: 'Stáhnout'
  information: 'Informace'
  type: 'Typ'
de:
  aspect_documentbrowser: 'Dokumentenbrowser'
  download: 'Herunterladen'
  information: 'Information'
  type: 'Typ'
en:
  aspect_documentbrowser: 'Document Browser'
  download: 'Download'
  information: 'Information'
  type: 'Type'
fr:
  aspect_documentbrowser: "Explorateur de fichier"
  download: "Télécharger"
  information: "Information"
  type: "Type"
