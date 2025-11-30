module ApplicationHelper
  # Returns Tailwind CSS classes for button styling based on variant
  # @param variant [Symbol] The button variant (:primary, :secondary, :danger, :success)
  # @return [String] Tailwind CSS classes for the button
  def button_classes(variant = :primary)
    base = "inline-flex items-center gap-2 px-4 py-2 rounded-lg font-medium transition-colors shadow-sm hover:shadow focus:outline-none focus:ring-2 focus:ring-offset-2"
    
    case variant
    when :primary
      "#{base} bg-indigo-600 text-white hover:bg-indigo-700 focus:ring-indigo-500"
    when :secondary
      "#{base} bg-white text-gray-700 border border-gray-300 hover:bg-gray-50 focus:ring-indigo-500"
    when :danger
      "#{base} bg-red-600 text-white hover:bg-red-700 focus:ring-red-500"
    when :success
      "#{base} bg-green-600 text-white hover:bg-green-700 focus:ring-green-500"
    else
      "#{base} bg-indigo-600 text-white hover:bg-indigo-700 focus:ring-indigo-500"
    end
  end

  # Returns Tailwind CSS classes for status badge styling
  # @param status [String, Symbol] The status type
  # @return [String] Tailwind CSS classes for the status badge
  def status_badge_classes(status)
    base = "inline-flex items-center px-3 py-1 rounded-full text-sm font-medium"
    
    case status.to_s.downcase
    when 'active'
      "#{base} bg-green-100 text-green-800"
    when 'inactive'
      "#{base} bg-red-100 text-red-800"
    when 'success'
      "#{base} bg-green-100 text-green-800"
    when 'failed'
      "#{base} bg-red-100 text-red-800"
    when 'in_progress'
      "#{base} bg-blue-100 text-blue-800"
    when 'pending'
      "#{base} bg-yellow-100 text-yellow-800"
    else
      "#{base} bg-gray-100 text-gray-800"
    end
  end
end
