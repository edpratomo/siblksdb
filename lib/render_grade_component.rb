module RenderGradeComponent
  def grade_component_as_table_heading inp, opt={}
    out = do_visit(inp, opt[:pkg])
    # enclose result with tr, and add columns as given in opt:
    render_result(out, opt)
  end

  class Node
    attr_accessor :colspan, :rowspan, :text

    def initialize(opt={})
      @text = ""
      opt[:colspan] and @colspan = opt[:colspan]
      opt[:text] and @text = opt[:text]
    end
  
    def to_th
      "<th" +
      (@colspan ? %[ colspan="#{@colspan}" ] : "") +
      (@rowspan ? %[ rowspan="#{@rowspan}" ] : "") +
      ">" + @text.to_s +
      "</th>"    
    end
  end

  private
  def render_result inp, opt
    heading_rows = inp.values.inject(0) do |m,o|
      m += o.size
    end

    inp.keys.each.with_index.sort {|a,b| a[0].to_i <=> b[0].to_i}.map do |k,i|
      inp[k].inject('') do |m,o|
        if i == 0
          m += "<tr>" + 
               (opt[:before] ? %[<th rowspan="#{heading_rows}">#{opt[:before]}</th>] : "") +
               o.map {|e| e.to_th}.join("") + 
               (opt[:after] ? %[<th rowspan="#{heading_rows}">#{opt[:after]}</th>] : "") +
               "</tr>"
        else
          m += "<tr>" + o.map {|e| e.to_th}.join("") + "</tr>"
        end
        m 
      end
    end.join("\n")
  end

  def visit out, structure, pkg, depth=0
    structure.each.with_index do |e,i|
      out[depth] ||= []
      if e.has_key? "members"
        out[depth][0] ||= []
        out[depth][0].push Node.new(text: e['group'], colspan: e['members'].size)
        visit(out, e['members'], pkg, depth + 1)
      elsif e.has_key? "code"
        code = eval e['code']
        x = code.call(pkg.course)
        x.each do |e|
          out[depth][0] ||= []
          out[depth][0].push Node.new(text: e['name'])
        end
      else
        out[depth][0] ||= []
        out[depth][0].push Node.new(text: e['component'])
        if e['scale']
          out[depth][1] ||= []
          out[depth][1].push Node.new(text: e['scale'])
        end
      end
    end
  end

  def do_visit structure, pkg
    out = {}
    visit(out, structure, pkg)
    out.each_with_index do |r,depth|
      next if depth == 0
      delta = out[depth - 1][0].size - out[depth][0].size
      if delta > 0
        rowspan = 1 + out[depth].size
        start = out[depth][0].size - 1
        (0..delta).each do |idx|
          out[depth - 1][0][start + idx].rowspan = rowspan
        end
      end
    end
    out
  end
end

if $0 == __FILE__
  require 'json'
  include RenderGradeComponent

  json_1 =<<"TEXT"
[
  {
    "group": "Paragraf",
    "members": [
      {
        "component": "Indentasi",
        "scale": 10
      },
      {
        "component": "Perataan Teks",
        "scale": 5
      },
      {
        "component": "Jarak Baris",
        "scale": 7.5
      },
      {
        "component": "Highlight",
        "scale": 5
      }
    ]
  },
  {
    "group": "Gambar",
    "members": [
      {
        "component": "Simbol",
        "scale": 5
      },
      {
        "component": "Text Wrap",
        "scale": 10
      },
      {
        "component": "Image Control",
        "scale": 5
      }
    ]
  },
  {
    "group": "Page Setup",
    "members": [
      {
        "component": "Margins",
        "scale": 5
      },
      {
        "component": "Paper Size",
        "scale": 5
      },
      {
        "component": "Effect",
        "scale": 10
      }
    ]
  },
  {
    "group": "Format Font",
    "members": [
      {
        "component": "Posisi Karakter",
        "scale": 10
      },
      {
        "component": "Spasi Karakter",
        "scale": 10
      }
    ]
  },
  {
    "group": "",
    "members": [
      {
        "component": "Header dan Footer",
        "scale": 7.5
      },
      {
        "component": "Ketelitian dan Kerapihan",
        "scale": 5
      }
    ]
  }
]
TEXT

json_2 =<<TEXT
[
  {
    "group": "Nilai",
    "members": [
      {
        "component": "Teori"
      },
      {
        "component": "Praktek"
      }
    ]
  },
  {
    "component": "Kualitas Pekerjaan"
  },
  {
    "component": "Fisik Mental dan Disiplin (FMD) - Terlambat/Kehadiran"
  },
  {
    "component": "Motivasi Kerja"
  },
  {
    "component": "Inisiatif & Kreativitas"
  },
  {
    "component": "Komunikasi"
  },
  {
    "component": "Rekomendasi"
  },
  {
    "component": "Keterangan"
  }
]
TEXT

  puts "<table border='1'><thead>" +
       grade_component_as_table_heading(JSON.parse(json_1), before: "Nilai", after: "Total") +
       "</thead></table>"

  puts "<table border='1'><thead>" +
       grade_component_as_table_heading(JSON.parse(json_2), before: "Nilai") +
       "</thead></table>"

end
