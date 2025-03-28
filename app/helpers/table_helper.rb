module TableHelper

    # Tabela simples com classes CSS atualizadas
    def table(headers, body, table_id)
      content_tag :div, class: 'overflow-x-auto w-full' do
        content_tag :table, id: table_id, class: 'highlight elegant-table w-full' do
          concat(content_tag(:thead) do
            content_tag(:tr) do
              headers.map { |header| content_tag(:th, header, class: 'header-cell center-align') }.join.html_safe
            end
          end)
          concat(content_tag(:tbody) do
            body.map do |row|
              content_tag(:tr) do
                row.map { |column| content_tag(:td, column, class: 'data-cell center-align') }.join.html_safe
              end
            end.join.html_safe
          end)
        end
      end
    end
  
    # Tabela de dados com estilos Tailwind CSS
    def data_table(rows, fix_to = 3)
      content_tag(:div, class: 'relative overflow-x-auto shadow-md sm:rounded-lg') do
        table_wrapper('scrollable', rows, 'min-w-full divide-y divide-gray-200 table-18', fix_to)
      end
    end
  
    def table_wrapper(id, rows, inner_classes, fix_to)
      if rows.empty?
        return content_tag(:p, 'Não houve resultados.', class: 'text-gray-500 text-center py-4')
      end
  
      content_tag(:table, class: inner_classes) do
        table_header(rows.first.map { |cell| cell[:header] }, fix_to) +
          table_body(rows, fix_to)
      end
    end
  
    def table_header(headers, fix_to)
        content_tag(:thead, class: 'bg-gray-50') do
          content_tag(:tr) do
            headers.map do |header|
              content_tag(:th, header, class: 'px-6 py-3 text-center text-gray-700 uppercase tracking-wider font-bold text-lg')
            end.join.html_safe
          end
        end
      end
  
    def table_body(rows, fix_to)
      content_tag(:tbody, class: 'bg-white divide-y divide-gray-200') do
        rows.map do |row|
          next if row.nil?
          content_tag(:tr, class: 'hover:bg-gray-50') do
            row.map do |cell|
              default_classes = "px-6 py-4 text-sm text-gray-500"
              cell_classes = cell[:class].present? ? "#{default_classes} #{cell[:class]}" : "#{default_classes} whitespace-nowrap text-center"
              content_tag(:td, cell[:content], id: cell[:id], class: cell_classes)
            end.join.html_safe
          end
        end.compact.join.html_safe
      end
    end
  
    # Tabela usando classes Tailwind CSS
    def tailwind_table(headers, body, table_id)
      content_tag :div, class: 'overflow-x-auto w-full' do
        content_tag :table, id: table_id, class: 'min-w-full divide-y divide-gray-200' do
          concat(content_tag(:thead, class: 'bg-gray-50') do
            content_tag(:tr) do
              headers.map { |header| content_tag(:th, header, class: 'px-6 py-3 text-center text-gray-700 uppercase tracking-wider font-bold text-lg') }.join.html_safe
            end
          end)
          concat(content_tag(:tbody, class: 'bg-white divide-y divide-gray-200') do
            body.map do |row|
              content_tag(:tr, class: 'hover:bg-gray-50') do
                row.map { |column| content_tag(:td, column, class: 'px-6 py-4 whitespace-nowrap text-sm text-gray-500 text-center') }.join.html_safe
              end
            end.join.html_safe
          end)
        end
      end
    end
  
  end
