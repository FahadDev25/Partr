# frozen_string_literal: true

module UltimateTurboModal::Flavors
  class Custom < UltimateTurboModal::Base
    DIV_DIALOG_CLASSES = "relative group z-50"
    DIV_OVERLAY_CLASSES = "fixed inset-0 bg-jet bg-opacity-50 transition-opacity dark:bg-opacity-80"
    DIV_OUTER_CLASSES = "fixed inset-0 overflow-y-auto"
    DIV_INNER_CLASSES = "flex min-h-full items-center justify-center p-1 sm:p-4"
    DIV_CONTENT_CLASSES = "relative transform overflow-hidden rounded-lg bg-snow text-left shadow transition-all modal-content scrollbar-hidden"
    DIV_MAIN_CLASSES = "group-data-[padding=true]:p-4 group-data-[padding=true]:pt-2"
    DIV_HEADER_CLASSES = "flex justify-between items-center w-full py-4 rounded-t dark:border-gray-600 group-data-[header-divider=true]:border-b group-data-[header=false]:absolute"
    DIV_TITLE_CLASSES = "pl-4"
    DIV_TITLE_H_CLASSES = "group-data-[title=false]:hidden text-lg font-semibold text-gray-900 dark:text-white"
    DIV_FOOTER_CLASSES = "flex p-4 rounded-b dark:border-gray-600 group-data-[footer-divider=true]:border-t"
    BUTTON_CLOSE_CLASSES = "mr-4 group-data-[close-button=false]:hidden"
    BUTTON_CLOSE_SR_ONLY_CLASSES = "sr-only"
    CLOSE_BUTTON_TAG_CLASSES = "text-gray-400 bg-transparent hover:bg-gray-200 hover:text-gray-900 rounded-lg text-sm p-1.5 ml-auto inline-flex items-center dark:hover:bg-gray-600 dark:hover:text-white"
    ICON_CLOSE_CLASSES = "w-5 h-5"
  end
end
