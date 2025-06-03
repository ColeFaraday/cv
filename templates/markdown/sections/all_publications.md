## Publications

<!-- [<a href="https://scholar.google.com/citations?user={{ scholar_id }}">Google Scholar</a>: {{ scholar_stats.citations }} citations and an h-index of {{ scholar_stats.h_index}}] <br> -->

See also: <a href="https://inspirehep.net/authors/{{ inspirehep_id }}">Inspire HEP</a>, <a href="https://scholar.google.com/citations?user={{ scholar_id }}">Google Scholar</a>, and <a href="https://scholar.google.com/citations?user={{ orcid }}"> ORCID </a>.

{% raw %}
{% assign pub_page = site.pages | where: "permalink", "/publications/" | first %}
<div class="publications">

{%- for section in pub_page.sections %}
  <a id="{{section.text}}"></a>
  <p class="bibtitle">{{section.text}}</p>
  {%- for y in pub_page.years %}

    {%- comment -%}  Count bibliography in actual section and year {%- endcomment -%}
    {%- capture citecount -%}
    {%- bibliography_count -f {{site.scholar.bibliography}} -q {{section.bibquery}}[year={{y}}] -%}
    {%- endcapture -%}

    {%- comment -%} If exist bibliography in actual section and year, print {%- endcomment -%}
    {%- if citecount !="0" %}

      <h2 class="year">{{y}}</h2>
      {% bibliography -f {{site.scholar.bibliography}} -q {{section.bibquery}}[year={{y}}] %}

    {%- endif -%}

  {%- endfor %}

{%- endfor %}

</div>


{% endraw %}